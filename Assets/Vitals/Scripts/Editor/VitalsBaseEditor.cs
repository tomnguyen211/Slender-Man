using UnityEditor;
using UnityEngine;

namespace Vitals.Editor
{
    [CustomEditor(typeof(VitalsBase), true), CanEditMultipleObjects]
    public class VitalsBaseEditor : UnityEditor.Editor
    {
        private VitalsBase _target;

        private SerializedProperty vitalsConfigProperty;
        private SerializedProperty saveOnQuitProperty;
        private SerializedProperty loadOnStartProperty;
        private SerializedProperty vitalsHookProperty;

        public override bool RequiresConstantRepaint() => true;

        private void OnEnable()
        {
            _target = (VitalsBase)target;
            vitalsConfigProperty = serializedObject.FindProperty("vitalsConfig");
            saveOnQuitProperty = serializedObject.FindProperty("saveOnQuit");
            loadOnStartProperty = serializedObject.FindProperty("loadOnStart");
            vitalsHookProperty = serializedObject.FindProperty("vitalsHook");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.PropertyField(vitalsConfigProperty);
            EditorGUILayout.Space();

            if (EditorApplication.isPlaying)
            {
                EditorGUILayout.LabelField("Value", _target.Value.ToString());
                EditorGUILayout.LabelField("Max Value", _target.MaxValue.ToString());
            }
            else if (_target.VitalsConfig != null)
            {
                EditorGUILayout.LabelField("Value", _target.VitalsConfig.value.ToString());
                EditorGUILayout.LabelField("Max Value", _target.VitalsConfig.maxValue.ToString());
            }

            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(vitalsHookProperty);
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(saveOnQuitProperty);
            EditorGUILayout.PropertyField(loadOnStartProperty);
            EditorGUILayout.Space();
            
            // Add clear save button
            if (GUILayout.Button("Clear Save"))
            {
                VitalsSaveUtility.ClearSave(_target);
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}