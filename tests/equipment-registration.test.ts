import { describe, it, expect } from 'vitest';

// Mock functions to simulate blockchain interactions
const mockEquipment = new Map();
const mockUser = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
const mockOtherUser = 'ST3CECAKJ4BH08JYY7W53MC81BYDT4YDA5M7S5F53';

// Mock contract functions
function registerEquipment(sender, equipmentId, facilityId, name, equipmentType, manufacturer) {
  if (mockEquipment.has(equipmentId)) {
    return { error: 1 };
  }
  
  mockEquipment.set(equipmentId, {
    facilityId,
    owner: sender,
    name,
    equipmentType,
    manufacturer,
    installationDate: 123456, // Mock block height
    lastMaintenanceDate: 123456, // Mock block height
    operationalStatus: true
  });
  
  return { success: true };
}

function updateMaintenance(sender, equipmentId) {
  if (!mockEquipment.has(equipmentId)) {
    return { error: 3 };
  }
  
  const equipment = mockEquipment.get(equipmentId);
  if (equipment.owner !== sender) {
    return { error: 2 };
  }
  
  equipment.lastMaintenanceDate = 123457; // Mock new block height
  mockEquipment.set(equipmentId, equipment);
  
  return { success: true };
}

function updateOperationalStatus(sender, equipmentId, status) {
  if (!mockEquipment.has(equipmentId)) {
    return { error: 5 };
  }
  
  const equipment = mockEquipment.get(equipmentId);
  if (equipment.owner !== sender) {
    return { error: 4 };
  }
  
  equipment.operationalStatus = status;
  mockEquipment.set(equipmentId, equipment);
  
  return { success: true };
}

function getEquipment(equipmentId) {
  return mockEquipment.get(equipmentId) || null;
}

function isOperational(equipmentId) {
  if (!mockEquipment.has(equipmentId)) {
    return false;
  }
  
  return mockEquipment.get(equipmentId).operationalStatus;
}

// Tests
describe('Equipment Registration Contract', () => {
  it('should register new equipment', () => {
    const result = registerEquipment(
        mockUser,
        'equip001',
        'facility001',
        'CNC Machine',
        'Machining',
        'MachineWorks Inc.'
    );
    
    expect(result.success).toBe(true);
    expect(mockEquipment.has('equip001')).toBe(true);
    
    const equipment = mockEquipment.get('equip001');
    expect(equipment.name).toBe('CNC Machine');
    expect(equipment.equipmentType).toBe('Machining');
    expect(equipment.manufacturer).toBe('MachineWorks Inc.');
    expect(equipment.operationalStatus).toBe(true);
  });
  
  it('should not register equipment with an existing ID', () => {
    // First registration
    registerEquipment(
        mockUser,
        'equip002',
        'facility001',
        '3D Printer',
        'Additive Manufacturing',
        'PrintTech Corp'
    );
    
    // Attempt to register with same ID
    const result = registerEquipment(
        mockUser,
        'equip002',
        'facility001',
        'Different Machine',
        'Different Type',
        'Different Manufacturer'
    );
    
    expect(result.error).toBe(1);
  });
  
  it('should allow owner to update maintenance date', () => {
    // Register equipment first
    registerEquipment(
        mockUser,
        'equip003',
        'facility001',
        'Robotic Arm',
        'Automation',
        'RoboSystems Ltd.'
    );
    
    // Update maintenance
    const result = updateMaintenance(mockUser, 'equip003');
    
    expect(result.success).toBe(true);
    
    const equipment = getEquipment('equip003');
    expect(equipment.lastMaintenanceDate).toBe(123457);
  });
  
  it('should not allow non-owner to update maintenance date', () => {
    // Register equipment first
    registerEquipment(
        mockUser,
        'equip004',
        'facility001',
        'Conveyor Belt',
        'Material Handling',
        'ConveyTech Inc.'
    );
    
    // Attempt to update with non-owner
    const result = updateMaintenance(mockOtherUser, 'equip004');
    
    expect(result.error).toBe(2);
  });
  
  it('should allow owner to update operational status', () => {
    // Register equipment first
    registerEquipment(
        mockUser,
        'equip005',
        'facility001',
        'Injection Molder',
        'Molding',
        'PlastiCorp'
    );
    
    // Update operational status
    const result = updateOperationalStatus(mockUser, 'equip005', false);
    
    expect(result.success).toBe(true);
    expect(isOperational('equip005')).toBe(false);
  });
  
  it('should not allow non-owner to update operational status', () => {
    // Register equipment first
    registerEquipment(
        mockUser,
        'equip006',
        'facility001',
        'Laser Cutter',
        'Cutting',
        'LaserTech Inc.'
    );
    
    // Attempt to update with non-owner
    const result = updateOperationalStatus(mockOtherUser, 'equip006', false);
    
    expect(result.error).toBe(4);
    expect(isOperational('equip006')).toBe(true);
  });
});
