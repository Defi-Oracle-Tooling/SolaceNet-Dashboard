import { investInStockMarket } from '../services/trust_services';
import { Request, Response } from 'express';

export async function handleStockMarketInvestment(req: Request, res: Response): Promise<void> {
  try {
    const { clientId, investmentDetails } = req.body;

    if (!clientId || !investmentDetails) {
      res.status(400).json({ error: 'Missing required fields: clientId or investmentDetails' });
      return;
    }

    const result = await investInStockMarket(clientId, investmentDetails);
    res.status(200).json({ message: result });
  } catch (error) {
    console.error('Error handling stock market investment:', error);
    res.status(500).json({ error: 'Failed to process stock market investment' });
  }
}
