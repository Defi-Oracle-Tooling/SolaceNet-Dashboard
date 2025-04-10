import { Router } from 'express';
import investmentBankingController from '../controllers/investmentBankingController';
// import other controllers as needed

const router = Router();

// Example route for investment banking
router.use('/investment-banking', investmentBankingController);

export default router;
