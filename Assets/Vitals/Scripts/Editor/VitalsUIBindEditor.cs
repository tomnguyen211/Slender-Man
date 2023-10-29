using System;
using UnityEditor;
using UnityEngine;

namespace Vitals.Editor
{
    [CustomEditor(typeof(VitalsUIBind))]
    public class VitalsUIBindEditor : UnityEditor.Editor
    {
        private VitalsUIBind _target;

        private SerializedProperty vitalsHookProperty;
        private SerializedProperty uiTypeProperty;
        private SerializedProperty fillImageProperty;
        private SerializedProperty sliderProperty;
        private SerializedProperty showTextFieldsProperty;
        private SerializedProperty valueTextProperty;
        private SerializedProperty maxValueTextProperty;
        private SerializedProperty boundThroughCodeProperty;
        private SerializedProperty animateChangesProperty;
        private SerializedProperty animationDurationProperty;
        private SerializedProperty animationCurveProperty;

        private void OnEnable()
        {
            _target = (VitalsUIBind)target;

            vitalsHookProperty = serializedObject.FindProperty("vitalsHook");
            uiTypeProperty = serializedObject.FindProperty("uiType");
            fillImageProperty = serializedObject.FindProperty("fillImage");
            sliderProperty = serializedObject.FindProperty("slider");
            showTextFieldsProperty = serializedObject.FindProperty("showTextFields");
            valueTextProperty = serializedObject.FindProperty("valueText");
            maxValueTextProperty = serializedObject.FindProperty("maxValueText");
            boundThroughCodeProperty = serializedObject.FindProperty("boundThroughCode");
            animateChangesProperty = serializedObject.FindProperty("animateChanges");
            animationDurationProperty = serializedObject.FindProperty("animationDuration");
            animationCurveProperty = serializedObject.FindProperty("animationCurve");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.LabelField("Vitals Hook", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(vitalsHookProperty);
            EditorGUILayout.PropertyField(boundThroughCodeProperty);
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Animation Settings", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(animateChangesProperty);
            if (_target.AnimateChanges)
            {
                EditorGUILayout.PropertyField(animationDurationProperty);
                EditorGUILayout.PropertyField(animationCurveProperty);
            }
            
            EditorGUILayout.Space();
            
            EditorGUILayout.LabelField("UI Settings", EditorStyles.boldLabel);
            EditorGUI.BeginProperty(Rect.zero, GUIContent.none, uiTypeProperty);
            EditorGUILayout.PropertyField(uiTypeProperty, new GUIContent("UI Type"));
            EditorGUI.EndProperty();

            switch (_target.UIType)
            {
                case UIType.Image:
                    EditorGUILayout.PropertyField(fillImageProperty);
                    break;
                case UIType.Slider:
                    EditorGUILayout.PropertyField(sliderProperty);
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            EditorGUILayout.PropertyField(showTextFieldsProperty);
            if (_target.ShowTextFields)
            {
                EditorGUILayout.PropertyField(valueTextProperty);
                EditorGUILayout.PropertyField(maxValueTextProperty);
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}