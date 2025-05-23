import { describe, it, expect } from 'vitest';

// Mock functions to simulate blockchain interactions
const mockOperationalData = new Map();
let mockDataPointCounter = 0;
const mockUser = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';

// Mock contract functions
function recordData(
    sender,
    equipmentId,
    temperature,
    pressure,
    vibration,
    powerConsumption,
    productionRate,
    qualityScore
) {
  const timestamp = 123456; // Mock block height
  const key = `${equipmentId}-${timestamp}`;
  
  if (mockOperationalData.has(key)) {
    return { error: 1 };
  }
  
  mockOperationalData.set(key, {
    temperature,
    pressure,
    vibration,
    powerConsumption,
    productionRate,
    qualityScore,
    operator: sender
  });
  
  mockDataPointCounter++;
  
  return { success: true };
}

function getData(equipmentId, timestamp) {
  const key = `${equipmentId}-${timestamp}`;
  return mockOperationalData.get(key) || null;
}

function getDataPointCount() {
  return mockDataPointCounter;
}

function dataExists(equipmentId, timestamp) {
  const key = `${equipmentId}-${timestamp}`;
  return mockOperationalData.has(key);
}

// Tests
describe('Operational Data Contract', () => {
  it('should record operational data', () => {
    const result = recordData(
        mockUser,
        'equip001',
        75, // temperature
        30, // pressure
        5,  // vibration
        1200, // power consumption
        150, // production rate
        95  // quality score
    );
    
    expect(result.success).toBe(true);
    expect(dataExists('equip001', 123456)).toBe(true);
    
    const data = getData('equip001', 123456);
    expect(data.temperature).toBe(75);
    expect(data.pressure).toBe(30);
    expect(data.vibration).toBe(5);
    expect(data.powerConsumption).toBe(1200);
    expect(data.productionRate).toBe(150);
    expect(data.qualityScore).toBe(95);
    expect(data.operator).toBe(mockUser);
  });
  
  it('should increment data point counter when recording data', () => {
    const initialCount = getDataPointCount();
    
    recordData(
        mockUser,
        'equip002',
        80, // temperature
        35, // pressure
        3,  // vibration
        1500, // power consumption
        200, // production rate
        98  // quality score
    );
    
    expect(getDataPointCount()).toBe(initialCount + 1);
  });
  
  it('should not record duplicate data for the same equipment and timestamp', () => {
    // First recording
    recordData(
        mockUser,
        'equip003',
        70, // temperature
        25, // pressure
        4,  // vibration
        1100, // power consumption
        140, // production rate
        92  // quality score
    );
    
    // Mock function to simulate trying to record at the same timestamp
    // In reality, block height would be different
    const result = recordData(
        mockUser,
        'equip003',
        72, // temperature
        26, // pressure
        4,  // vibration
        1150, // power consumption
        145, // production rate
        93  // quality score
    );
    
    expect(result.error).toBe(1);
    
    // Original data should remain unchanged
    const data = getData('equip003', 123456);
    expect(data.temperature).toBe(70);
    expect(data.pressure).toBe(25);
  });
  
  it('should correctly report if data exists', () => {
    // Record data for a new equipment
    recordData(
        mockUser,
        'equip004',
        65, // temperature
        20, // pressure
        2,  // vibration
        900, // power consumption
        120, // production rate
        90  // quality score
    );
    
    expect(dataExists('equip004', 123456)).toBe(true);
    expect(dataExists('equip004', 123457)).toBe(false);
    expect(dataExists('nonexistent', 123456)).toBe(false);
  });
});
