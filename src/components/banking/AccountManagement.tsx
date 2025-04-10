import React, { useState, useEffect } from 'react';
import { 
  Container, 
  Typography, 
  Box, 
  Card, 
  CardContent, 
  Grid, 
  Button, 
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
  CircularProgress,
  Alert
} from '@mui/material';
import { AccountCircle, Payment, CreditCard, ReceiptLong } from '@mui/icons-material';
import { openAndMaintainBankAccounts, issueCreditCardsAndContracts, provideComplianceBankServices } from '../../services/banking_services';
import './AccountManagement.css';

interface Account {
  id: string;
  accountNumber: string;
  accountType: string;
  balance: number;
  currency: string;
  status: string;
  createdAt: string;
}

const AccountManagement: React.FC = () => {
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [openCreateDialog, setOpenCreateDialog] = useState<boolean>(false);
  const [newAccountType, setNewAccountType] = useState<string>('checking');
  const [newAccountCurrency, setNewAccountCurrency] = useState<string>('USD');
  
  useEffect(() => {
    const loadAccounts = async () => {
      try {
        setLoading(true);
        const data = await openAndMaintainBankAccounts();
        setAccounts(data);
        setError(null);
      } catch (err) {
        setError('Failed to load accounts.');
      } finally {
        setLoading(false);
      }
    };
    
    loadAccounts();
  }, []);
  
  const handleCreateAccount = async () => {
    // In a real app, this would make an API call to create a new account
    try {
      setLoading(true);
      // Mock new account for demo
      const newAccount = {
        id: `acc-${Date.now()}`,
        accountNumber: `${Math.floor(Math.random() * 10000000000)}`,
        accountType: newAccountType,
        balance: 0,
        currency: newAccountCurrency,
        status: 'active',
        createdAt: new Date().toISOString()
      };
      
      // In a real app, call an API to create the account
      // await createAccount(newAccount);
      
      // Update local state
      setAccounts([...accounts, newAccount]);
      setOpenCreateDialog(false);
      
    } catch (err) {
      setError('Failed to create account. Please try again later.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };
  
  const getAccountIcon = (accountType: string) => {
    switch (accountType.toLowerCase()) {
      case 'checking':
        return <Payment fontSize="large" />;
      case 'savings':
        return <CreditCard fontSize="large" />;
      case 'investment':
        return <ReceiptLong fontSize="large" />;
      default:
        return <AccountCircle fontSize="large" />;
    }
  };
  
  const formatCurrency = (amount: number, currency: string) => {
    return new Intl.NumberFormat('en-US', { 
      style: 'currency', 
      currency: currency 
    }).format(amount);
  };
  
  const handleOpenCreateDialog = () => {
    setOpenCreateDialog(true);
  };
  
  const handleCloseCreateDialog = () => {
    setOpenCreateDialog(false);
  };

  return (
    <Container maxWidth="lg">
      <Box mt={4} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4" component="h1">
          Account Management
        </Typography>
        <Button 
          variant="contained" 
          color="primary"
          onClick={handleOpenCreateDialog}
        >
          Create New Account
        </Button>
      </Box>
      
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      
      {loading && accounts.length === 0 ? (
        <Box display="flex" justifyContent="center" my={4}>
          <CircularProgress />
        </Box>
      ) : accounts.length === 0 ? (
        <Alert severity="info">
          You don't have any accounts yet. Create your first account to get started.
        </Alert>
      ) : (
        <Grid container spacing={3}>
          {accounts.map((account) => (
            <Grid item xs={12} md={6} lg={4} key={account.id} className="account-grid-item">
              <Card>
                <CardContent>
                  <Box display="flex" alignItems="center" mb={2}>
                    {getAccountIcon(account.accountType)}
                    <Typography variant="h6" component="div" ml={1} sx={{ textTransform: 'capitalize' }}>
                      {account.accountType} Account
                    </Typography>
                  </Box>
                  
                  <Typography color="textSecondary" gutterBottom>
                    Account Number: {account.accountNumber}
                  </Typography>
                  
                  <Typography variant="h5" component="div">
                    {formatCurrency(account.balance, account.currency)}
                  </Typography>
                  
                  <Box mt={2} display="flex" justifyContent="space-between">
                    <Typography color="textSecondary">
                      Status: <div className={account.status === 'active' ? 'status-active' : 'status-inactive'}>
                        {account.status}
                      </div>
                    </Typography>
                    
                    <Typography color="textSecondary">
                      {new Date(account.createdAt).toLocaleDateString()}
                    </Typography>
                  </Box>
                  
                  <Box mt={2} display="flex" justifyContent="flex-end">
                    <Button size="small" color="primary">
                      View Details
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}
      
      {/* Create Account Dialog */}
      <Dialog open={openCreateDialog} onClose={handleCloseCreateDialog}>
        <DialogTitle>Create New Account</DialogTitle>
        <DialogContent>
          <Box mt={1}>
            <FormControl fullWidth margin="normal">
              <InputLabel id="account-type-label">Account Type</InputLabel>
              <Select
                labelId="account-type-label"
                value={newAccountType}
                label="Account Type"
                onChange={(e) => setNewAccountType(e.target.value)}
              >
                <MenuItem value="checking">Checking Account</MenuItem>
                <MenuItem value="savings">Savings Account</MenuItem>
                <MenuItem value="investment">Investment Account</MenuItem>
                <MenuItem value="trust">Trust Account</MenuItem>
              </Select>
            </FormControl>
            
            <FormControl fullWidth margin="normal">
              <InputLabel id="currency-label">Currency</InputLabel>
              <Select
                labelId="currency-label"
                value={newAccountCurrency}
                label="Currency"
                onChange={(e) => setNewAccountCurrency(e.target.value)}
              >
                <MenuItem value="USD">US Dollar (USD)</MenuItem>
                <MenuItem value="EUR">Euro (EUR)</MenuItem>
                <MenuItem value="GBP">British Pound (GBP)</MenuItem>
                <MenuItem value="JPY">Japanese Yen (JPY)</MenuItem>
                <MenuItem value="BTC">Bitcoin (BTC)</MenuItem>
                <MenuItem value="ETH">Ethereum (ETH)</MenuItem>
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseCreateDialog}>Cancel</Button>
          <Button onClick={handleCreateAccount} variant="contained" color="primary">
            Create
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default AccountManagement;
