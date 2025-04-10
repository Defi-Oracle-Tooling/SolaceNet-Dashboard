import { Router, Request, Response } from 'express';
import { provideGlobalInvestmentBankingServices, issueAndTradeSecurities, offerFinancialGuarantees } from '../services/investment_banking';

const router = Router();

// GET /investment-banking/global-services
router.get('/global-services', (req: Request, res: Response) => {
  const result = provideGlobalInvestmentBankingServices();
  return res.json({ success: true, data: result });
});

// POST /investment-banking/securities
router.post('/securities', (req: Request, res: Response) => {
  const result = issueAndTradeSecurities();
  return res.json({ success: true, data: result });
});

// POST /investment-banking/guarantees
router.post('/guarantees', (req: Request, res: Response) => {
  const result = offerFinancialGuarantees();
  return res.json({ success: true, data: result });
});

export default router;
