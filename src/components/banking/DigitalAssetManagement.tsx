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

interface DigitalAsset {
  id: string;
  name: string;
  type: string;
  value: number;
  currency: string;
  createdDate: string;
}

const mockDigitalAssets: DigitalAsset[] = [
  {
    id: 'asset-1',
    name: 'Bitcoin',
    type: 'Cryptocurrency',
    value: 45000,
    currency: 'USD',
    createdDate: '2023-01-01'
  },
  {
    id: 'asset-2',
    name: 'Ethereum',
    type: 'Cryptocurrency',
    value: 3000,
    currency: 'USD',
    createdDate: '2022-06-15'
  }
];

const DigitalAssetManagement: React.FC = () => {
  const [digitalAssets, setDigitalAssets] = useState<DigitalAsset[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Add digital asset dialog
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [newDigitalAsset, setNewDigitalAsset] = useState<Partial<DigitalAsset>>({
    name: '',
    type: '',
    value: 0,
    currency: 'USD'
  });

  useEffect(() => {
    const loadDigitalAssets = async () => {
      try {
        setLoading(true);
        // Simulate API call
        setTimeout(() => {
          setDigitalAssets(mockDigitalAssets);
          setError(null);
          setLoading(false);
        }, 1000);
      } catch (err) {
        setError('Failed to load digital assets. Please try again later.');
        console.error(err);
        setLoading(false);
      }
    };

    loadDigitalAssets();
  }, []);

  const handleOpenAddDialog = () => {
    setOpenAddDialog(true);
  };

  const handleCloseAddDialog = () => {
    setOpenAddDialog(false);
  };

  const handleAddDigitalAsset = () => {
    const createdDigitalAsset: DigitalAsset = {
      id: `asset-${Date.now()}`,
      name: newDigitalAsset.name || '',
      type: newDigitalAsset.type || 'General',
      value: newDigitalAsset.value || 0,
      currency: newDigitalAsset.currency || 'USD',
      createdDate: new Date().toISOString().split('T')[0]
    };

    setDigitalAssets([...digitalAssets, createdDigitalAsset]);
    setOpenAddDialog(false);
    setNewDigitalAsset({
      name: '',
      type: '',
      value: 0,
      currency: 'USD'
    });
  };

  const handleDeleteDigitalAsset = (assetId: string) => {
    setDigitalAssets(digitalAssets.filter(asset => asset.id !== assetId));
  };

  return (
    <Container maxWidth="lg">
      <Box mt={4} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4" component="h1">
          Digital Asset Management
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<Add />}
          onClick={handleOpenAddDialog}
        >
          Add Digital Asset
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
                  <TableCell align="right">Created Date</TableCell>
                  <TableCell align="right">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {digitalAssets.map((asset) => (
                  <TableRow key={asset.id}>
                    <TableCell>{asset.name}</TableCell>
                    <TableCell>{asset.type}</TableCell>
                    <TableCell align="right">{asset.value.toLocaleString()}</TableCell>
                    <TableCell align="right">{asset.currency}</TableCell>
                    <TableCell align="right">{asset.createdDate}</TableCell>
                    <TableCell align="right">
                      <IconButton size="small">
                        <Edit fontSize="small" />
                      </IconButton>
                      <IconButton size="small" onClick={() => handleDeleteDigitalAsset(asset.id)}>
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

      {/* Add Digital Asset Dialog */}
      <Dialog open={openAddDialog} onClose={handleCloseAddDialog} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Digital Asset</DialogTitle>
        <DialogContent>
          <Box mt={1}>
            <TextField
              fullWidth
              margin="normal"
              label="Asset Name"
              value={newDigitalAsset.name}
              onChange={(e) => setNewDigitalAsset({ ...newDigitalAsset, name: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Type"
              value={newDigitalAsset.type}
              onChange={(e) => setNewDigitalAsset({ ...newDigitalAsset, type: e.target.value })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Value"
              type="number"
              value={newDigitalAsset.value}
              onChange={(e) => setNewDigitalAsset({ ...newDigitalAsset, value: parseFloat(e.target.value) })}
            />

            <TextField
              fullWidth
              margin="normal"
              label="Currency"
              value={newDigitalAsset.currency}
              onChange={(e) => setNewDigitalAsset({ ...newDigitalAsset, currency: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAddDialog}>Cancel</Button>
          <Button onClick={handleAddDigitalAsset} variant="contained" color="primary">
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default DigitalAssetManagement;
