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

interface CustodianAsset {
  id: string;
  name: string;
  type: string;
  value: number;
  currency: string;
  receiptNumber: string;
  createdDate: string;
}

const mockCustodianAssets: CustodianAsset[] = [
  {
    id: 'custodian-1',
    name: 'Gold Bar',
    type: 'Precious Metal',
    value: 50000,
    currency: 'USD',
    receiptNumber: 'SKR-001',
    createdDate: '2023-01-01'
  },
  {
    id: 'custodian-2',
    name: 'Real Estate',
    type: 'Property',
    value: 300000,
    currency: 'USD',
    receiptNumber: 'SKR-002',
    createdDate: '2022-06-15'
  }
];

const CustodianFiduciaryServices: React.FC = () => {
  const [custodianAssets, setCustodianAssets] = useState<CustodianAsset[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Add custodian asset dialog
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [newCustodianAsset, setNewCustodianAsset] = useState<Partial<CustodianAsset>>({
    name: '',
    type: '',
    value: 0,
    currency: 'USD',
    receiptNumber: ''
  });

  useEffect(() => {
    const loadCustodianAssets = async () => {
      try {
        setLoading(true);
        // Simulate API call
        setTimeout(() => {
          setCustodianAssets(mockCustodianAssets);
          setError(null);
          setLoading(false);
        }, 1000);
      } catch (err) {
        setError('Failed to load custodian assets. Please try again later.');
        console.error(err);
        setLoading(false);
      }
    };

    loadCustodianAssets();
  }, []);

  const handleOpenAddDialog = () => {
    setOpenAddDialog(true);
  };

  const handleCloseAddDialog = () => {
    setOpenAddDialog(false);
  };

  const handleAddCustodianAsset = () => {
    const createdCustodianAsset: CustodianAsset = {
      id: `custodian-${Date.now()}`,
      name: newCustodianAsset.name || '',
      type: newCustodianAsset.type || 'General',
      value: newCustodianAsset.value || 0,
      currency: newCustodianAsset.currency || 'USD',
      receiptNumber: newCustodianAsset.receiptNumber || `SKR-${Date.now()}`,
      createdDate: new Date().toISOString().split('T')[0]
    };

    setCustodianAssets([...custodianAssets, createdCustodianAsset]);
    setOpenAddDialog(false);
    setNewCustodianAsset({
      name: '',
      type: '',
      value: 0,
      currency: 'USD',
      receiptNumber: ''
    });
  };

  const handleDeleteCustodianAsset = (assetId: string) => {
    setCustodianAssets(custodianAssets.filter(asset => asset.id !== assetId));
  };

  return (
    <Container maxWidth="lg">
      <Box mt={4} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4" component="h1">
          Custodian & Fiduciary Services
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<Add />}
          onClick={handleOpenAddDialog}
        >
          Add Custodian Asset
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
                  <TableCell>Asset Name</TableCell>
                  <TableCell>Type</TableCell>
                  <TableCell align="right">Value</TableCell>
                  <TableCell align="right">Currency</TableCell>
                  <TableCell align="right">Receipt Number</TableCell>
                  <TableCell align="right">Created Date</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {custodianAssets.map((asset) => (
                  <TableRow key={asset.id}>
                    <TableCell>{asset.name}</TableCell>
                    <TableCell>{asset.type}</TableCell>
                    <TableCell align="right">{asset.value.toLocaleString()}</TableCell>
                    <TableCell align="right">{asset.currency}</TableCell>
                    <TableCell align="right">{asset.receiptNumber}</TableCell>
                    <TableCell align="right">{asset.createdDate}</TableCell>
                    <TableCell align="right">
                      <IconButton size="small">
                        <Edit fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleDeleteCustodianAsset(asset.id)}>
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

      {/* Add Custodian Asset Dialog */}
      <Dialog open={openAddDialog} onClose={handleCloseAddDialog} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Custodian Asset</DialogTitle>
        <DialogContent>
          <Box mt={1}>
            <TextField
              fullWidth
              margin="normal"
              label="Asset Name"
              value={newCustodianAsset.name}
              onChange={(e) => setNewCustodianAsset({ ...newCustodianAsset, name: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Type"
              value={newCustodianAsset.type}
              onChange={(e) => setNewCustodianAsset({ ...newCustodianAsset, type: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Value"
              type="number"
              value={newCustodianAsset.value}
              onChange={(e) => setNewCustodianAsset({ ...newCustodianAsset, value: parseFloat(e.target.value) })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Currency"
              value={newCustodianAsset.currency}
              onChange={(e) => setNewCustodianAsset({ ...newCustodianAsset, currency: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Receipt Number"
              value={newCustodianAsset.receiptNumber}
              onChange={(e) => setNewCustodianAsset({ ...newCustodianAsset, receiptNumber: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAddDialog}>Cancel</Button>
          <Button onClick={handleAddCustodianAsset} variant="contained" color="primary">
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default CustodianFiduciaryServices;
