import * as admin from 'firebase-admin';
import { onCall, onRequest, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import * as dotenv from 'dotenv';
import { RazorpayService } from './razorpay/razorpay_service';

dotenv.config();

admin.initializeApp();

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || '';
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || '';
const RAZORPAY_WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || '';

const razorpay = new RazorpayService(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET);

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
                status: 'active',
                accessType: 'paid',
            }, { merge: true });
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
