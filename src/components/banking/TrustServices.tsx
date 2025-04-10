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
  Alert,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton
} from '@mui/material';
import { Add, Edit, Delete } from '@mui/icons-material';

interface TrustAccount {
  id: string;
  name: string;
  type: string;
  balance: number;
  currency: string;
  createdDate: string;
}

const mockTrustAccounts: TrustAccount[] = [
  {
    id: 'trust-1',
    name: 'Family Trust',
    type: 'Real Estate',
    balance: 500000,
    currency: 'USD',
    createdDate: '2023-01-01'
  },
  {
    id: 'trust-2',
    name: 'Investment Trust',
    type: 'Stocks',
    balance: 250000,
    currency: 'USD',
    createdDate: '2022-06-15'
  }
];

const TrustServices: React.FC = () => {
  const [trustAccounts, setTrustAccounts] = useState<TrustAccount[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Add trust account dialog
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [newTrustAccount, setNewTrustAccount] = useState<Partial<TrustAccount>>({
    name: '',
    type: '',
    balance: 0,
    currency: 'USD'
  });

  useEffect(() => {
    const loadTrustAccounts = async () => {
      try {
        setLoading(true);
        // Simulate API call
        setTimeout(() => {
          setTrustAccounts(mockTrustAccounts);
          setError(null);
          setLoading(false);
        }, 1000);
      } catch (err) {
        setError('Failed to load trust accounts. Please try again later.');
        console.error(err);
        setLoading(false);
      }
    };

    loadTrustAccounts();
  }, []);

  const handleOpenAddDialog = () => {
    setOpenAddDialog(true);
  };

  const handleCloseAddDialog = () => {
    setOpenAddDialog(false);
  };

  const handleAddTrustAccount = () => {
    const createdTrustAccount: TrustAccount = {
      id: `trust-${Date.now()}`,
      name: newTrustAccount.name || '',
      type: newTrustAccount.type || 'General',
      balance: newTrustAccount.balance || 0,
      currency: newTrustAccount.currency || 'USD',
      createdDate: new Date().toISOString().split('T')[0]
    };

    setTrustAccounts([...trustAccounts, createdTrustAccount]);
    setOpenAddDialog(false);
    setNewTrustAccount({
      name: '',
      type: '',
      balance: 0,
      currency: 'USD'
    });
  };

  const handleDeleteTrustAccount = (trustId: string) => {
    setTrustAccounts(trustAccounts.filter(account => account.id !== trustId));
  };

  return (
    <Container maxWidth="lg">
      <Box mt={4} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4" component="h1">
          Trust Services
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<Add />}
          onClick={handleOpenAddDialog}
        >
          Add Trust Account
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {loading ? (
        <Box display="flex" justifyContent="center" my={4}>
          <CircularProgress />
        </Box>
      ) : (
        <Paper>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Trust Name</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell align="right">Balance</TableCell>
                  <TableCell align="right">Currency</TableCell>
                  <TableCell align="right">Created Date</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {trustAccounts.map((account) => (
                  <TableRow key={account.id}>
                    <TableCell>{account.name}</TableCell>
                    <TableCell>{account.type}</TableCell>
                    <TableCell align="right">{account.balance.toLocaleString()}</TableCell>
                    <TableCell align="right">{account.currency}</TableCell>
                    <TableCell align="right">{account.createdDate}</TableCell>
                    <TableCell align="right">
                      <IconButton size="small">
                        <Edit fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleDeleteTrustAccount(account.id)}>
                        <Delete fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      {/* Add Trust Account Dialog */}
      <Dialog open={openAddDialog} onClose={handleCloseAddDialog} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Trust Account</DialogTitle>
        <DialogContent>
          <Box mt={1}>
            <TextField
              fullWidth
              margin="normal"
              label="Trust Name"
              value={newTrustAccount.name}
              onChange={(e) => setNewTrustAccount({ ...newTrustAccount, name: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Type"
              value={newTrustAccount.type}
              onChange={(e) => setNewTrustAccount({ ...newTrustAccount, type: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Balance"
              type="number"
              value={newTrustAccount.balance}
              onChange={(e) => setNewTrustAccount({ ...newTrustAccount, balance: parseFloat(e.target.value) })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Currency"
              value={newTrustAccount.currency}
              onChange={(e) => setNewTrustAccount({ ...newTrustAccount, currency: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAddDialog}>Cancel</Button>
          <Button onClick={handleAddTrustAccount} variant="contained" color="primary">
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default TrustServices;
