using System;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

namespace Vitals
{
    /// <summary>
    /// A class responsible for saving and loading Vitals data.
    /// </summary>
    public static class VitalsSaveUtility
    {

        #region Old Save/Load Methods

        [Obsolete("This method is obsolete starting V2")]
        public static void Save(float value, float maxValue, string fileName)
        {
            VitalSaveData vitalSaveData = new VitalSaveData(value, maxValue);
            var path = Application.persistentDataPath + "/" + fileName + ".data";
            SaveData(vitalSaveData, path);
        }
        
        [Obsolete("This method is obsolete starting V2")]
        public static VitalSaveData Load(string fileName)
        {
            var path = Application.persistentDataPath + "/" + fileName + ".data";
            
            if (File.Exists(path))
            {
                FileStream fileStream = new FileStream(path, FileMode.Open);
                BinaryFormatter binaryFormatter = new BinaryFormatter();
                VitalSaveData vitalSaveData = binaryFormatter.Deserialize(fileStream) as VitalSaveData;
                fileStream.Close();
                return vitalSaveData;
            }

            Debug.LogError("Save file not found in " + path);
            return null;
        }

        #endregion
        
        /// <summary>
        /// Saves the values of the given Vitals Component to a binary file with a path using the name of the object that has the component and the name of the component.
        /// </summary>
        /// <param name="vitalsBase">The vitals component to save</param>
        public static void Save(VitalsBase vitalsBase)
        {
            var value = vitalsBase.Value;
            var maxValue = vitalsBase.MaxValue;
            VitalSaveData vitalSaveData = new VitalSaveData(value, maxValue);
            var path = Application.persistentDataPath + "/" + vitalsBase.gameObject.name + "_" + vitalsBase.GetType().Name + ".data";
            SaveData(vitalSaveData, path);
        }
        
        /// <summary>
        /// Loads the values of the given Vitals Component from an existing save file.
        /// </summary>
        /// <param name="vitalsBase"></param>
        /// <returns>True if load is successful</returns>
        public static bool Load(VitalsBase vitalsBase)
        {
            var path = Application.persistentDataPath + "/" + vitalsBase.gameObject.name + "_" + vitalsBase.GetType().Name + ".data";
            
            if (File.Exists(path))
            {
                FileStream fileStream = new FileStream(path, FileMode.Open);
                BinaryFormatter binaryFormatter = new BinaryFormatter();
                VitalSaveData vitalSaveData = binaryFormatter.Deserialize(fileStream) as VitalSaveData;
                fileStream.Close();
                if (vitalSaveData != null)
                {
                    vitalsBase.SetMax(vitalSaveData.maxValue);
                    vitalsBase.Set(vitalSaveData.value);
                }
                return true;
            }
            
            vitalsBase.Reload();
            return false;
        }
        
        /// <summary>
        /// Deletes the save file of the given Vitals Component.
        /// </summary>
        /// <param name="vitalsBase"></param>
        public static void ClearSave(VitalsBase vitalsBase)
        {
            var path = Application.persistentDataPath + "/" + vitalsBase.gameObject.name + "_" + vitalsBase.GetType().Name + ".data";
            
            if (File.Exists(path))
            {
                File.Delete(path);
                Debug.Log("Save file for " + vitalsBase.gameObject.name + " in " + path + " has been deleted.");
            }
            else
            {
                Debug.Log("Save file for " + vitalsBase.gameObject.name + " in " + path + " does not exist.");
            }
        }
        
        /// <summary>
        /// A method for saving data to a binary file.
        /// </summary>
        /// <param name="data">Data class instance</param>
        /// <param name="path">Save path</param>
        /// <typeparam name="T">Data class</typeparam>
        private static void SaveData<T>(T data, string path)
        {
            FileStream fileStream = new FileStream(path, FileMode.Create);
            BinaryFormatter binaryFormatter = new BinaryFormatter();
            binaryFormatter.Serialize(fileStream, data);
            
            fileStream.Close();
        }
    }
    
    /// <summary>
    /// Data class for saving Vitals data.
    /// </summary>
    [Serializable]
    public class VitalSaveData
    {
        public float value;
        public float maxValue;

        public VitalSaveData(float value, float maxValue)
        {
            this.value = value;
            this.maxValue = maxValue;
        }
    }
}
