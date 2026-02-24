
export const busStops = [
  {
    id: '1',
    name: 'Central Station',
    address: '123 Main Street',
    latitude: 40.7128,
    longitude: -74.0060,
    routes: ['Route 1', 'Route 5', 'Route 12'],
    accessibility: {
      wheelchairAccessible: true,
      audioAnnouncements: true,
      tactilePaving: true
    }
  },
  {
    id: '2',
    name: 'City Hospital',
    address: '456 Health Avenue',
    latitude: 40.7589,
    longitude: -73.9851,
    routes: ['Route 3', 'Route 7', 'Route 15'],
    accessibility: {
      wheelchairAccessible: true,
      audioAnnouncements: true,
      tactilePaving: true
    }
  },
  {
    id: '3',
    name: 'University Campus',
    address: '789 Education Boulevard',
    latitude: 40.7282,
    longitude: -73.7949,
    routes: ['Route 2', 'Route 8', 'Route 11'],
    accessibility: {
      wheelchairAccessible: true,
      audioAnnouncements: true,
      tactilePaving: false
    }
  },
  {
    id: '4',
    name: 'Shopping Center',
    address: '321 Commerce Street',
    latitude: 40.7505,
    longitude: -73.9934,
    routes: ['Route 4', 'Route 9', 'Route 13'],
    accessibility: {
      wheelchairAccessible: true,
      audioAnnouncements: false,
      tactilePaving: true
    }
  },
  {
    id: '5',
    name: 'Park Avenue',
    address: '654 Park Avenue',
    latitude: 40.7614,
    longitude: -73.9776,
    routes: ['Route 6', 'Route 10', 'Route 14'],
    accessibility: {
      wheelchairAccessible: false,
      audioAnnouncements: true,
      tactilePaving: true
    }
  }
];

export const busRoutes = [
  {
    id: 'route-1',
    name: 'Route 1',
    color: '#FF6B6B',
    stops: ['1', '2', '4'],
    frequency: 15,
    operatingHours: '6:00 AM - 11:00 PM'
  },
  {
    id: 'route-2',
    name: 'Route 2',
    color: '#4ECDC4',
    stops: ['3', '5', '1'],
    frequency: 20,
    operatingHours: '5:30 AM - 12:00 AM'
  },
  {
    id: 'route-3',
    name: 'Route 3',
    color: '#45B7D1',
    stops: ['2', '4', '5'],
    frequency: 12,
    operatingHours: '6:30 AM - 10:30 PM'
  }
];

export const favoriteStops = [
  {
    id: '1',
    name: 'Central Station',
    nickname: 'Work',
    lastUsed: '2024-01-15T08:30:00Z'
  },
  {
    id: '2',
    name: 'City Hospital',
    nickname: 'Doctor',
    lastUsed: '2024-01-10T14:15:00Z'
  }
];

export const recentSearches = [
  'Central Station to City Hospital',
  'University Campus to Shopping Center',
  'Park Avenue to Central Station'
];
