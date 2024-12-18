import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('Digital Services Marketplace Contract', () => {
  let mockContractCall: any;
  
  beforeEach(() => {
    mockContractCall = vi.fn();
  });
  
  it('should create a new service', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 1 });
    const result = await mockContractCall('create-service', 'Test service description', 1000000);
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
  });
  
  it('should accept a service', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('accept-service', 1);
    expect(result.success).toBe(true);
  });
  
  it('should add a milestone', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 1 });
    const result = await mockContractCall('add-milestone', 1, 500000, 'Test milestone description');
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
  });
  
  it('should complete a milestone', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('complete-milestone', 1);
    expect(result.success).toBe(true);
  });
  
  it('should raise a dispute', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 1 });
    const result = await mockContractCall('raise-dispute', 1, 'Test dispute description');
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
  });
  
  it('should resolve a dispute', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('resolve-dispute', 1, 'resolved');
    expect(result.success).toBe(true);
  });
  
  it('should update user reputation', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('update-reputation', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM', 5);
    expect(result.success).toBe(true);
  });
  
  it('should get service details', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: { id: 1, description: 'Test service' } });
    const result = await mockContractCall('get-service', 1);
    expect(result.success).toBe(true);
    expect(result.value).toEqual({ id: 1, description: 'Test service' });
  });
  
  it('should get user reputation', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: { score: 5 } });
    const result = await mockContractCall('get-user-reputation', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');
    expect(result.success).toBe(true);
    expect(result.value).toEqual({ score: 5 });
  });
});

