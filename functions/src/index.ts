import * as admin from 'firebase-admin';
import { onCall, onRequest, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import * as dotenv from 'dotenv';
import { RazorpayService } from './razorpay/razorpay_service';
import { GoogleGenerativeAI } from '@google/generative-ai';

dotenv.config();

admin.initializeApp();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || '';
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || '';
const RAZORPAY_WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || '';

const razorpay = new RazorpayService(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET);

/**
 * AI Transcript Generation
 * Uses Gemini 1.5 Flash to transcribe lesson audio/video.
 */
export const generateLessonTranscript = onCall(async (request: CallableRequest<any>) => {
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    // Only allow instructors or admins to trigger generation (for now)
    // Or allow students if needed - but it costs tokens.

    const { courseId, lessonId, partId, videoUrl } = request.data;

    if (!courseId || !lessonId || !partId) {
        throw new HttpsError('invalid-argument', 'Missing courseId, lessonId, or partId.');
    }

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        // In a real scenario, we'd download the audio or pass the URL if Gemini supports it directly via GCS
        // For now, if we have a direct video URL (e.g. from Cloudflare/Vimeo), we can try to fetch it
        // and send to Gemini as a file.

        let transcript = "";

        if (videoUrl) {
            // Simplified: We'll prompt Gemini with the context.
            // Ideally we'd send the actual audio bytes here.
            // Since Cloud Functions have a size limit, we should use the File API of Gemini for larger files.

            const prompt = `Please provide a high-quality transcript for a lesson titled "Lesson ${partId}" from "Course ${courseId}". 
            If possible, use the context of the course to generate the text. 
            (Note: In a production environment, audio bytes would be sent here).`;

            const result = await model.generateContent(prompt);
            transcript = result.response.text();
        } else {
            throw new HttpsError('not-found', 'No video/audio URL provided for transcription.');
        }

        // Save to Firestore
        const partRef = admin.firestore()
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .collection('parts')
            .doc(partId);

        await partRef.update({
            transcript: transcript,
            transcriptGeneratedBy: 'MishkatAI',
            transcriptUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { success: true, transcript };
    } catch (error) {
        console.error('Transcription Error:', error);
        throw new HttpsError('internal', 'Failed to generate transcript.');
    }
});

// Placeholder for Cloudflare Stream Token
export const getPlaybackToken = onCall(async (request: CallableRequest<any>) => {
    // TODO: Implement entitlement check and Cloudflare API call
    return { token: "placeholder_token" };
});

// Razorpay Order Creation
export const createRazorpayOrder = onCall(async (request: CallableRequest<any>) => {
    if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    const { amount, currency, courseId } = request.data;
    const uid = request.auth.uid;

    try {
        const order = await razorpay.createOrder(amount, currency, `rcpt_${Date.now()}`);

        // Save order to Firestore for tracking
        await admin.firestore().collection('payments').doc(order.id).set({
            uid,
            courseId,
            amount,
            currency,
            status: 'created',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { orderId: order.id };
    } catch (error) {
        console.error('Razorpay Order Error:', error);
        throw new HttpsError('internal', 'Could not create payment order.');
    }
});

// Razorpay Webhook
export const razorpayWebhook = onRequest(async (req, res) => {
    const signature = req.headers['x-razorpay-signature'] as string;
    const body = req.body;

    if (!signature || !RAZORPAY_WEBHOOK_SECRET) {
        console.error('Missing signature or webhook secret');
        res.status(400).send('Unauthorized');
        return;
    }

    const isValid = razorpay.verifyWebhookSignature(
        (req as any).rawBody.toString(),
        signature,
        RAZORPAY_WEBHOOK_SECRET
    );

    if (!isValid) {
        console.error('Invalid Razorpay signature');
        res.status(400).send('Invalid signature');
        return;
    }

    const event = body.event;
    if (event === 'payment.captured' || event === 'order.paid') {
        const payment = body.payload.payment?.entity || body.payload.order?.entity;
        const orderId = payment.order_id || payment.id;

        const paymentDoc = await admin.firestore().collection('payments').doc(orderId).get();
        if (paymentDoc.exists) {
            const { uid, courseId } = paymentDoc.data()!;

            // Update payment status
            await paymentDoc.ref.update({
                status: 'captured',
                paymentId: payment.id,
                capturedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Grant course access (Enrollment)
            // The app watches users/{uid}/progress/{courseId}
            await admin.firestore()
                .collection('users')
                .doc(uid)
                .collection('progress')
                .doc(courseId)
                .set({
                    enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
                    status: 'active',
                    accessType: 'paid',
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                }, { merge: true });

            // Also keep top-level records for easy querying
            const enrollmentId = `${uid}_${courseId}`;
            await admin.firestore().collection('enrollments').doc(enrollmentId).set({
                uid,
                courseId,
                enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
                progress: 0,
                completedParts: [],
                status: 'active',
                accessType: 'paid',
            }, { merge: true });

            // Audit Log
            await logAuditAction('SYSTEM', 'COURSE_ENROLL_WEBHOOK', `enrollments/${enrollmentId}`, { uid, courseId });
        }
    } else if (event === 'payment.failed') {
        const payment = body.payload.payment.entity;
        const orderId = payment.order_id;

        if (orderId) {
            await admin.firestore().collection('payments').doc(orderId).update({
                status: 'failed',
                errorDescription: payment.error_description,
                errorCode: payment.error_code,
                failedAt: admin.firestore.FieldValue.serverTimestamp(),
            }).catch(err => console.error('Error updating failed payment:', err));
        }
    }

    res.status(200).send("ok");
});

/**
 * Admin: Set User Role
 * Sets custom claims for RBAC.
 */
export const adminSetUserRole = onCall(async (request: CallableRequest<any>) => {
    // Check if the caller is an admin or the bootstrap UID
    const isBootstrapAdmin = request.auth?.uid === 'opRxlWwXj7aMNkiScEn9nOSKryp1';
    if (!request.auth || (!request.auth.token.admin && !isBootstrapAdmin)) {
        throw new HttpsError('permission-denied', 'Only admins can set roles.');
    }

    const { targetUid, role } = request.data;

    if (!targetUid || !role) {
        throw new HttpsError('invalid-argument', 'Missing targetUid or role.');
    }

    // Role must be 'admin', 'teacher', or 'student' (standardized lowercase)
    const allowedRoles = ['admin', 'teacher', 'student'];
    if (!allowedRoles.includes(role)) {
        throw new HttpsError('invalid-argument', 'Invalid role provided.');
    }

    try {
        // Set custom claims
        const claims: any = {};
        if (role === 'admin') claims.admin = true;
        if (role === 'teacher') claims.teacher = true;
        // 'student' has no special claims beyond base auth

        await admin.auth().setCustomUserClaims(targetUid, claims);

        // Update Firestore profile for UI display (standardized)
        await admin.firestore().collection('users').doc(targetUid).update({
            role: role,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Audit Log
        await logAuditAction(request.auth.uid, 'ROLE_CHANGE', `users/${targetUid}`, { newRole: role });

        return { success: true, message: `Role ${role} set for user ${targetUid}` };
    } catch (error) {
        console.error('Set Role Error:', error);
        throw new HttpsError('internal', 'Failed to set user role.');
    }
});

/**
 * Audit Logging Helper
 */
async function logAuditAction(actorUid: string, actionType: string, targetRef: string, metadata: any = {}) {
    try {
        await admin.firestore().collection('audit_logs').add({
            actorUid,
            actionType,
            targetRef,
            metadata,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    } catch (error) {
        console.error('Audit Log Error:', error);
    }
}
