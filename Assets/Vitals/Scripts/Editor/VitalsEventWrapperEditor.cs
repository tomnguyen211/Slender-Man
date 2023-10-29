using UnityEditor;
using Vitals;

namespace Vitals.Editor
{
    [CustomEditor(typeof(VitalsEventWrapper))]
    public class VitalsEventWrapperEditor : UnityEditor.Editor
    {
    SerializedProperty vitalsComponentProperty;
    SerializedProperty regenerationComponentProperty;

    SerializedProperty onValueIncreaseProperty;
    SerializedProperty onValueDecreaseProperty;
    SerializedProperty onMaxValueIncreaseProperty;
    SerializedProperty onMaxValueDecreaseProperty;
    SerializedProperty onValueFullProperty;
    SerializedProperty onValueEmptyProperty;

    SerializedProperty onRegenerationStartProperty;
    SerializedProperty onRegenerationStopProperty;
    SerializedProperty onDrainStartProperty;
    SerializedProperty onDrainStopProperty;

    bool showVitalsEvents = false;
    bool showRegenerationEvents = false;

    private void OnEnable()
    {
        vitalsComponentProperty = serializedObject.FindProperty("vitalsComponent");
        regenerationComponentProperty = serializedObject.FindProperty("regenerationComponent");

        onValueIncreaseProperty = serializedObject.FindProperty("onValueIncrease");
        onValueDecreaseProperty = serializedObject.FindProperty("onValueDecrease");
        onMaxValueIncreaseProperty = serializedObject.FindProperty("onMaxValueIncrease");
        onMaxValueDecreaseProperty = serializedObject.FindProperty("onMaxValueDecrease");
        onValueFullProperty = serializedObject.FindProperty("onValueFull");
        onValueEmptyProperty = serializedObject.FindProperty("onValueEmpty");

        onRegenerationStartProperty = serializedObject.FindProperty("onRegenerationStart");
        onRegenerationStopProperty = serializedObject.FindProperty("onRegenerationStop");
        onDrainStartProperty = serializedObject.FindProperty("onDrainStart");
        onDrainStopProperty = serializedObject.FindProperty("onDrainStop");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(vitalsComponentProperty);
        EditorGUILayout.PropertyField(regenerationComponentProperty);
        EditorGUILayout.Space();

        
        if (vitalsComponentProperty.objectReferenceValue != null)
        {
            showVitalsEvents = EditorGUILayout.Foldout(showVitalsEvents, "Vitals Events");
            if (showVitalsEvents)
            {
                EditorGUILayout.PropertyField(onValueIncreaseProperty);
                EditorGUILayout.PropertyField(onValueDecreaseProperty);
                EditorGUILayout.PropertyField(onMaxValueIncreaseProperty);
                EditorGUILayout.PropertyField(onMaxValueDecreaseProperty);
                EditorGUILayout.PropertyField(onValueFullProperty);
                EditorGUILayout.PropertyField(onValueEmptyProperty);
            }
        }

        
        if (regenerationComponentProperty.objectReferenceValue != null)
        {
            showRegenerationEvents = EditorGUILayout.Foldout(showRegenerationEvents, "Regeneration Events");
            if (showRegenerationEvents)
            {
                EditorGUILayout.PropertyField(onRegenerationStartProperty);
                EditorGUILayout.PropertyField(onRegenerationStopProperty);
                EditorGUILayout.PropertyField(onDrainStartProperty);
                EditorGUILayout.PropertyField(onDrainStopProperty);
            }
        }

        serializedObject.ApplyModifiedProperties();
    }
    }
}