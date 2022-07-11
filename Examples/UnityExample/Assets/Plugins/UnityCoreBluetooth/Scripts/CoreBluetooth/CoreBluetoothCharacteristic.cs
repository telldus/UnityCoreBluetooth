﻿using System;

#if UNITY_EDITOR_OSX || UNITY_IOS
namespace UnityCoreBluetooth
{
    public class CoreBluetoothCharacteristic
    {
        private readonly IntPtr nativePtr;
        public CoreBluetoothCharacteristic(IntPtr ptr)
        {
            this.nativePtr = ptr;
        }

        private string _uuid = null;
        public string Uuid
        {
            get
            {
                if (_uuid == null) _uuid = NativeInterface.UcbCharacteristic.ucb_characteristic_getUuid(nativePtr);
                return _uuid;
            }
        }

        private string[] _propertis = null;
        public string[] Propertis
        {
            get
            {
                if (_propertis == null) _propertis = NativeInterface.UcbCharacteristic.ucb_characteristic_getPropertis(nativePtr).Split(',');
                return _propertis;
            }
        }

        public CoreBluetoothService Service
        {
            get
            {
                return new CoreBluetoothService(NativeInterface.UcbCharacteristic.ucb_characteristic_getService(nativePtr));
            }
        }

        public CoreBluetoothPeripheral Peripheral
        {
            get
            {
                return new CoreBluetoothPeripheral(NativeInterface.UcbCharacteristic.ucb_characteristic_getPeripheral(nativePtr));
            }
        }

        public void Write(byte[] value)
        {
            NativeInterface.UcbCharacteristic.ucb_characteristic_write(nativePtr, value, value.Length);
        }

        public void Read()
        {
            NativeInterface.UcbCharacteristic.ucb_characteristic_read(nativePtr);
        }

        public void SetNotifyValue(bool enable)
        {
            NativeInterface.UcbCharacteristic.ucb_characteristic_setNotify(nativePtr, enable);
        }
    }
}
#endif
