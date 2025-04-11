import { Router } from 'express';
import investmentBankingController, { handleTrustPropertyManagement } from '../controllers/investmentBankingController';

const router = Router();

// Example route for investment banking
router.use('/investment-banking', investmentBankingController);
router.post('/trust-property-management', handleTrustPropertyManagement);

export default router;
