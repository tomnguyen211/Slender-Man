using UnityEditor;

namespace Vitals.Editor
{
    [CustomEditor(typeof(HealthRegeneration), true)]
    public class RegenerationEditor : UnityEditor.Editor
    {
        SerializedProperty _componentProperty;

        private void OnEnable()
        {
            // Cache the SerializedProperty for the component field
            if (target is HealthRegeneration)
            {
                _componentProperty = serializedObject.FindProperty("healthComponent");
            }
            else if (target is StaminaRegeneration)
            {
                _componentProperty = serializedObject.FindProperty("staminaComponent");
            }
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            // Draw the component field
            if (_componentProperty != null)
            {
                EditorGUILayout.PropertyField(_componentProperty);
            }

            // Draw the fields from the parent class
            if (target is HealthRegeneration)
            {
                DrawPropertiesExcluding(serializedObject, "healthComponent", "m_Script");
            }
            else if (target is StaminaRegeneration)
            {
                DrawPropertiesExcluding(serializedObject, "staminaComponent", "m_Script");
            }

            serializedObject.ApplyModifiedProperties();
        }
    }

    [CustomEditor(typeof(StaminaRegeneration), true)]
    public class StaminaRegenerationEditor : RegenerationEditor
    {
        
    }
}