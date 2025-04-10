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
  Alert,
  Tabs,
  Tab,
  Paper,
  Divider,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton
} from '@mui/material';
import { 
  TrendingUp, 
  TrendingDown, 
  Apartment, 
  Diamond,
  Insights, 
  Add, 
  Edit, 
  Delete,
  CurrencyBitcoin,
  ShowChart
} from '@mui/icons-material';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`asset-tabpanel-${index}`}
      aria-labelledby={`asset-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ p: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

interface Asset {
  id: string;
  name: string;
  type: string;
  value: number;
  currency: string;
  quantity?: number;
  purchaseDate?: string;
  performance?: {
    daily: number;
    monthly: number;
    yearly: number;
  };
}

const mockAssets: Asset[] = [
  {
    id: 'asset-1',
    name: 'Apple Inc.',
    type: 'stocks',
    value: 150000,
    currency: 'USD',
    quantity: 1000,
    purchaseDate: '2023-01-15',
    performance: {
      daily: 2.5,
      monthly: 7.2,
      yearly: 22.1
    }
  },
  {
    id: 'asset-2',
    name: 'US Treasury Bond 2.5%',
    type: 'bonds',
    value: 250000,
    currency: 'USD',
    purchaseDate: '2022-09-20',
    performance: {
      daily: 0.02,
      monthly: 0.18,
      yearly: 2.45
    }
  },
  {
    id: 'asset-3',
    name: 'Manhattan Office Building',
    type: 'real_estate',
    value: 4500000,
    currency: 'USD',
    purchaseDate: '2020-06-30',
    performance: {
      daily: 0,
      monthly: 0.4,
      yearly: 5.8
    }
  },
  {
    id: 'asset-4',
    name: 'Bitcoin',
    type: 'crypto',
    value: 180000,
    currency: 'USD',
    quantity: 3.5,
    purchaseDate: '2021-03-15',
    performance: {
      daily: -3.2,
      monthly: 12.5,
      yearly: 45.2
    }
  }
];

const AssetManagement: React.FC = () => {
  const [tabValue, setTabValue] = useState(0);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  
  // Add asset dialog
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [newAsset, setNewAsset] = useState<Partial<Asset>>({
    name: '',
    type: 'stocks',
    value: 0,
    currency: 'USD'
  });

  useEffect(() => {
    const loadAssets = async () => {
      try {
        setLoading(true);
        // In a real app, this would make an API call to fetch user assets
        // const data = await fetchUserAssets();
        // Simulating API call with timeout
        setTimeout(() => {
          setAssets(mockAssets);
          setError(null);
          setLoading(false);
        }, 1000);
      } catch (err) {
        setError('Failed to load assets. Please try again later.');
        console.error(err);
        setLoading(false);
      }
    };
    
    loadAssets();
  }, []);
  
  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
  };
  
  const getAssetIcon = (assetType: string) => {
    switch (assetType) {
      case 'stocks':
        return <ShowChart fontSize="large" />;
      case 'bonds':
        return <Insights fontSize="large" />;
      case 'real_estate':
        return <Apartment fontSize="large" />;
      case 'crypto':
        return <CurrencyBitcoin fontSize="large" />;
      case 'precious_metals':
        return <Diamond fontSize="large" />;
      default:
        return <Insights fontSize="large" />;
    }
  };
  
  const formatCurrency = (amount: number, currency: string) => {
    return new Intl.NumberFormat('en-US', { 
      style: 'currency', 
      currency: currency,
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };
  
  const getTotalAssetValue = (type?: string) => {
    if (type) {
      return assets
        .filter(asset => asset.type === type)
        .reduce((total, asset) => total + asset.value, 0);
    }
    
    return assets.reduce((total, asset) => total + asset.value, 0);
  };
  
  const getAssetsByType = (type: string) => {
    return assets.filter(asset => asset.type === type);
  };
  
  const handleOpenAddDialog = () => {
    setOpenAddDialog(true);
  };
  
  const handleCloseAddDialog = () => {
    setOpenAddDialog(false);
  };
  
  const handleAddAsset = () => {
    const createdAsset: Asset = {
      id: `asset-${Date.now()}`,
      name: newAsset.name || '',
      type: newAsset.type || 'stocks',
      value: newAsset.value || 0,
      currency: newAsset.currency || 'USD',
      quantity: newAsset.quantity,
      purchaseDate: new Date().toISOString().split('T')[0],
      performance: {
        daily: 0,
        monthly: 0,
        yearly: 0
      }
    };
    
    setAssets([...assets, createdAsset]);
    setOpenAddDialog(false);
    setNewAsset({
      name: '',
      type: 'stocks',
      value: 0,
      currency: 'USD'
    });
  };
  
  const handleDeleteAsset = (assetId: string) => {
    setAssets(assets.filter(asset => asset.id !== assetId));
  };

  return (
    <Container maxWidth="lg">
      <Box mt={4} mb={2} display="flex" justifyContent="space-between" alignItems="center">
        <Typography variant="h4" component="h1">
          Asset Management
        </Typography>
        <Button 
          variant="contained" 
          color="primary"
          startIcon={<Add />}
          onClick={handleOpenAddDialog}
        >
          Add Asset
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
        <>
          {/* Portfolio Summary Card */}
          <Card sx={{ mb: 4 }}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                Total Portfolio Value
              </Typography>
              <Typography variant="h3" component="div" color="primary" gutterBottom>
                {formatCurrency(getTotalAssetValue(), 'USD')}
              </Typography>
              
              <Grid container spacing={3} mt={1}>
                <Grid item xs={12} sm={6} md={3}>
                  <Typography variant="subtitle1" color="text.secondary">Stocks</Typography>
                  <Typography variant="h6">{formatCurrency(getTotalAssetValue('stocks'), 'USD')}</Typography>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Typography variant="subtitle1" color="text.secondary">Bonds</Typography>
                  <Typography variant="h6">{formatCurrency(getTotalAssetValue('bonds'), 'USD')}</Typography>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Typography variant="subtitle1" color="text.secondary">Real Estate</Typography>
                  <Typography variant="h6">{formatCurrency(getTotalAssetValue('real_estate'), 'USD')}</Typography>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Typography variant="subtitle1" color="text.secondary">Cryptocurrencies</Typography>
                  <Typography variant="h6">{formatCurrency(getTotalAssetValue('crypto'), 'USD')}</Typography>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
          
          {/* Asset Tabs */}
          <Paper sx={{ mt: 3 }}>
            <Tabs
              value={tabValue}
              onChange={handleTabChange}
              indicatorColor="primary"
              textColor="primary"
              variant="scrollable"
              scrollButtons="auto"
            >
              <Tab label="All Assets" />
              <Tab label="Stocks" />
              <Tab label="Bonds" />
              <Tab label="Real Estate" />
              <Tab label="Cryptocurrencies" />
            </Tabs>
            
            <TabPanel value={tabValue} index={0}>
              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Asset</TableCell>
                      <TableCell>Type</TableCell>
                      <TableCell align="right">Value</TableCell>
                      <TableCell align="right">Daily</TableCell>
                      <TableCell align="right">Monthly</TableCell>
                      <TableCell align="right">Yearly</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {assets.map((asset) => (
                      <TableRow key={asset.id}>
                        <TableCell>
                          <Box display="flex" alignItems="center">
                            {getAssetIcon(asset.type)}
                            <Typography sx={{ ml: 1 }}>{asset.name}</Typography>
                          </Box>
                        </TableCell>
                        <TableCell sx={{ textTransform: 'capitalize' }}>
                          {asset.type.replace('_', ' ')}
                        </TableCell>
                        <TableCell align="right">{formatCurrency(asset.value, asset.currency)}</TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end">
                            {asset.performance?.daily && asset.performance.daily > 0 ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                            <Typography color={asset.performance?.daily && asset.performance.daily > 0 ? 'success.main' : 'error.main'}>
                              {asset.performance?.daily}%
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end">
                            {asset.performance?.monthly && asset.performance.monthly > 0 ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                            <Typography color={asset.performance?.monthly && asset.performance.monthly > 0 ? 'success.main' : 'error.main'}>
                              {asset.performance?.monthly}%
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end">
                            {asset.performance?.yearly && asset.performance.yearly > 0 ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                            <Typography color={asset.performance?.yearly && asset.performance.yearly > 0 ? 'success.main' : 'error.main'}>
                              {asset.performance?.yearly}%
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">
                          <IconButton size="small">
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDeleteAsset(asset.id)}>
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </TabPanel>
            
            <TabPanel value={tabValue} index={1}>
              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Stock</TableCell>
                      <TableCell align="right">Quantity</TableCell>
                      <TableCell align="right">Value</TableCell>
                      <TableCell align="right">Performance (YTD)</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {getAssetsByType('stocks').map((asset) => (
                      <TableRow key={asset.id}>
                        <TableCell>{asset.name}</TableCell>
                        <TableCell align="right">{asset.quantity}</TableCell>
                        <TableCell align="right">{formatCurrency(asset.value, asset.currency)}</TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end">
                            {asset.performance?.yearly && asset.performance.yearly > 0 ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                            <Typography color={asset.performance?.yearly && asset.performance.yearly > 0 ? 'success.main' : 'error.main'}>
                              {asset.performance?.yearly}%
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">
                          <IconButton size="small">
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDeleteAsset(asset.id)}>
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </TabPanel>
            
            <TabPanel value={tabValue} index={2}>
              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Bond</TableCell>
                      <TableCell align="right">Value</TableCell>
                      <TableCell align="right">Yield</TableCell>
                      <TableCell align="right">Maturity Date</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {getAssetsByType('bonds').map((asset) => (
                      <TableRow key={asset.id}>
                        <TableCell>{asset.name}</TableCell>
                        <TableCell align="right">{formatCurrency(asset.value, asset.currency)}</TableCell>
                        <TableCell align="right">{asset.performance?.yearly}%</TableCell>
                        <TableCell align="right">2030-01-01</TableCell>
                        <TableCell align="right">
                          <IconButton size="small">
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDeleteAsset(asset.id)}>
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </TabPanel>
            
            <TabPanel value={tabValue} index={3}>
              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Property</TableCell>
                      <TableCell align="right">Value</TableCell>
                      <TableCell align="right">Annual Return</TableCell>
                      <TableCell align="right">Purchase Date</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {getAssetsByType('real_estate').map((asset) => (
                      <TableRow key={asset.id}>
                        <TableCell>{asset.name}</TableCell>
                        <TableCell align="right">{formatCurrency(asset.value, asset.currency)}</TableCell>
                        <TableCell align="right">{asset.performance?.yearly}%</TableCell>
                        <TableCell align="right">{asset.purchaseDate}</TableCell>
                        <TableCell align="right">
                          <IconButton size="small">
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDeleteAsset(asset.id)}>
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </TabPanel>
            
            <TabPanel value={tabValue} index={4}>
              <TableContainer>
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Cryptocurrency</TableCell>
                      <TableCell align="right">Quantity</TableCell>
                      <TableCell align="right">Value</TableCell>
                      <TableCell align="right">24h Change</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {getAssetsByType('crypto').map((asset) => (
                      <TableRow key={asset.id}>
                        <TableCell>
                          <Box display="flex" alignItems="center">
                            <CurrencyBitcoin />
                            <Typography sx={{ ml: 1 }}>{asset.name}</Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">{asset.quantity}</TableCell>
                        <TableCell align="right">{formatCurrency(asset.value, asset.currency)}</TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end">
                            {asset.performance?.daily && asset.performance.daily > 0 ? <TrendingUp color="success" /> : <TrendingDown color="error" />}
                            <Typography color={asset.performance?.daily && asset.performance.daily > 0 ? 'success.main' : 'error.main'}>
                              {asset.performance?.daily}%
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell align="right">
                          <IconButton size="small">
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton size="small" onClick={() => handleDeleteAsset(asset.id)}>
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </TabPanel>
          </Paper>
        </>
      )}
      
      {/* Add Asset Dialog */}
      <Dialog open={openAddDialog} onClose={handleCloseAddDialog} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Asset</DialogTitle>
        <DialogContent>
          <Box mt={1}>
            <TextField
              fullWidth
              margin="normal"
              label="Asset Name"
              value={newAsset.name}
              onChange={(e) => setNewAsset({ ...newAsset, name: e.target.value })}
            />
            
            <FormControl fullWidth margin="normal">
              <InputLabel id="asset-type-label">Asset Type</InputLabel>
              <Select
                labelId="asset-type-label"
                value={newAsset.type}
                label="Asset Type"
                onChange={(e) => setNewAsset({ ...newAsset, type: e.target.value })}
              >
                <MenuItem value="stocks">Stocks</MenuItem>
                <MenuItem value="bonds">Bonds</MenuItem>
                <MenuItem value="real_estate">Real Estate</MenuItem>
                <MenuItem value="crypto">Cryptocurrency</MenuItem>
                <MenuItem value="precious_metals">Precious Metals</MenuItem>
                <MenuItem value="commodities">Commodities</MenuItem>
              </Select>
            </FormControl>
            
            <TextField
              fullWidth
              margin="normal"
              label="Value"
              type="number"
              value={newAsset.value}
              onChange={(e) => setNewAsset({ ...newAsset, value: parseFloat(e.target.value) })}
            />
            
            <FormControl fullWidth margin="normal">
              <InputLabel id="currency-label">Currency</InputLabel>
              <Select
                labelId="currency-label"
                value={newAsset.currency}
                label="Currency"
                onChange={(e) => setNewAsset({ ...newAsset, currency: e.target.value })}
              >
                <MenuItem value="USD">US Dollar (USD)</MenuItem>
                <MenuItem value="EUR">Euro (EUR)</MenuItem>
                <MenuItem value="GBP">British Pound (GBP)</MenuItem>
                <MenuItem value="JPY">Japanese Yen (JPY)</MenuItem>
                <MenuItem value="BTC">Bitcoin (BTC)</MenuItem>
              </Select>
            </FormControl>
            
            {(newAsset.type === 'stocks' || newAsset.type === 'crypto') && (
              <TextField
                fullWidth
                margin="normal"
                label="Quantity"
                type="number"
                value={newAsset.quantity || ''}
                onChange={(e) => setNewAsset({ ...newAsset, quantity: parseFloat(e.target.value) })}
              />
            )}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAddDialog}>Cancel</Button>
          <Button onClick={handleAddAsset} variant="contained" color="primary">
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default AssetManagement;
