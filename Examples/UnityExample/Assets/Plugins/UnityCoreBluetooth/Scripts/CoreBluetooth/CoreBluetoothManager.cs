using System;
using UnityEngine;

#if UNITY_EDITOR_OSX || UNITY_IOS
namespace UnityCoreBluetooth
{
    public class CoreBluetoothManager
    {
        public void OnUpdateState(Action<string> action)
        {
            wrapper.OnUpdateStateHandler = action;
        }

        public void OnDiscoverPeripheral(Action<CoreBluetoothPeripheral, string, int> action)
        {
            wrapper.OnDiscoverPeripheralHandler = (IntPtr ptr, string advertisementData, int rssi) =>
            {
                action(new CoreBluetoothPeripheral(ptr), advertisementData, rssi);
            };
        }

        public void OnConnectPeripheral(Action<CoreBluetoothPeripheral> action)
        {
            wrapper.OnConnectPeripheralHandler = (IntPtr ptr) =>
            {
                action(new CoreBluetoothPeripheral(ptr));
            };
        }

        public void OnDiscoverService(Action<CoreBluetoothService> action)
        {
            wrapper.OnDiscoverServiceHandler = (IntPtr ptr) =>
            {
                action(new CoreBluetoothService(ptr));
            };
        }

        public void OnDiscoverCharacteristic(Action<CoreBluetoothCharacteristic> action)
        {
            wrapper.OnDiscoverCharacteristicHandler = (IntPtr ptr) =>
            {
                action(new CoreBluetoothCharacteristic(ptr));
            };
        }

        public void OnUpdateValue(Action<CoreBluetoothCharacteristic, byte[]> action)
        {
            wrapper.OnUpdateValueHandler = (IntPtr ptr, byte[] data) =>
            {
                action(new CoreBluetoothCharacteristic(ptr), data);
            };
        }

        public void OnUpdateRSSI(Action<CoreBluetoothPeripheral, int> action)
        {
            wrapper.OnUpdateRSSIHandler = (IntPtr ptr, int rssi) =>
            {
                action(new CoreBluetoothPeripheral(ptr), rssi);
            };
        }

        public void OnDisconnectPeripheral(Action<CoreBluetoothPeripheral, string> action)
        {
            wrapper.OnDisconnectPeripheralHandler = (IntPtr ptr, string error) =>
            {
                action(new CoreBluetoothPeripheral(ptr), error);
            };
        }

        private readonly NativeInterface.UnityCoreBluetoothManagerWrapper wrapper;

        private CoreBluetoothManager()
        {
            Debug.Log("CoreBluetoothManager init");
            wrapper = NativeInterface.UnityCoreBluetoothManagerWrapper.Shared;
        }

        private static CoreBluetoothManager _shared;
        public static CoreBluetoothManager Shared
        {
            get
            {
                Debug.Log("get CoreBluetoothManager");
                if (_shared == null) _shared = new CoreBluetoothManager();
                return _shared;
            }
        }

        public void Start()
        {
            wrapper.Start();
        }

        public void Stop()
        {
            wrapper.Stop();
        }

        public void StartScan()
        {
            wrapper.StartScan();
        }

        public void StopScan()
        {
            wrapper.StopScan();
        }

        public void ConnectToPeripheral(CoreBluetoothPeripheral peripheral)
        {
            wrapper.ConnectToPeripheral(peripheral.nativePtr);
        }
    }
}
#endif
