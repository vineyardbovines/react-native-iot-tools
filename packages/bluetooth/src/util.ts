import { BufferTypes } from ".";

// behold my monstrosity
export function handleBufferData({
  buffer,
  dataType,
  offset,
  byteLength
}: {
  buffer: Buffer;
  dataType: BufferTypes;
  offset?: number;
  byteLength?: number;
}) {
  switch (dataType) {
    case BufferTypes.BIGINT64_BE:
      return Buffer.from(buffer).readBigInt64BE(offset);
    case BufferTypes.BIGINT64_LE:
      return Buffer.from(buffer).readBigInt64LE(offset);
    case BufferTypes.BIGUINT64_BE:
      return Buffer.from(buffer).readBigUInt64BE(offset);
    case BufferTypes.BIGUINT64_LE:
      return Buffer.from(buffer).readBigUInt64LE(offset);
    case BufferTypes.DOUBLE_BE:
      return Buffer.from(buffer).readDoubleBE(offset);
    case BufferTypes.DOUBLE_LE:
      return Buffer.from(buffer).readDoubleLE(offset);
    case BufferTypes.FLOAT_BE:
      return Buffer.from(buffer).readFloatBE(offset);
    case BufferTypes.FLOAT_LE:
      return Buffer.from(buffer).readFloatLE(offset);
    case BufferTypes.INT8:
      return Buffer.from(buffer).readInt8(offset);
    case BufferTypes.UINT8:
      return Buffer.from(buffer).readUInt8(offset);
    case BufferTypes.INT16_BE:
      return Buffer.from(buffer).readInt16BE(offset);
    case BufferTypes.INT16_LE:
      return Buffer.from(buffer).readInt16LE(offset);
    case BufferTypes.UINT16_BE:
      return Buffer.from(buffer).readUInt16BE(offset);
    case BufferTypes.UINT16_LE:
      return Buffer.from(buffer).readUInt16LE(offset);
    case BufferTypes.INT32_BE:
      return Buffer.from(buffer).readInt32BE(offset);
    case BufferTypes.INT32_LE:
      return Buffer.from(buffer).readInt32LE(offset);
    case BufferTypes.UINT32_BE:
      return Buffer.from(buffer).readUInt32BE(offset);
    case BufferTypes.UINT32_LE:
      return Buffer.from(buffer).readUInt32LE(offset);
    case BufferTypes.INT_BE:
      return Buffer.from(buffer).readIntBE(offset ?? 0, byteLength ?? 1);
    case BufferTypes.INT_LE:
      return Buffer.from(buffer).readIntLE(offset ?? 0, byteLength ?? 1);
    case BufferTypes.UINT_BE:
      return Buffer.from(buffer).readUIntBE(offset ?? 0, byteLength ?? 1);
    case BufferTypes.UINT_LE:
      return Buffer.from(buffer).readUIntLE(offset ?? 0, byteLength ?? 1);
    case BufferTypes.STRING:
      return Buffer.from(buffer).toString();
    default:
      return Buffer.from(buffer).readInt8(offset);
  }
}
