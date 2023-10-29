using UnityEditor;
using UnityEngine.SceneManagement;

namespace Vitals.Editor
{
    [CustomEditor(typeof(VitalsConfig))]
    public class ConfigEditor : UnityEditor.Editor
    {
        private void OnEnable()
        {
            Undo.postprocessModifications += OnPostProcessModifications;
        }

        private void OnDisable()
        {
            Undo.postprocessModifications -= OnPostProcessModifications;
        }
        
        private UndoPropertyModification[] OnPostProcessModifications(UndoPropertyModification[] modifications)
        {
            foreach (var modification in modifications)
            {
                if (modification.currentValue.target is VitalsConfig scriptableObject)
                {
                    ReloadAllMyComponents(scriptableObject);
                }
            }

            return modifications;
        }

        private void ReloadAllMyComponents(VitalsConfig scriptableObject)
        {
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                var rootObjects = scene.GetRootGameObjects();

                foreach (var rootObject in rootObjects)
                {
                    var myComponents = rootObject.GetComponentsInChildren<VitalsBase>();

                    foreach (var myComponent in myComponents)
                    {
                        if (myComponent.VitalsConfig == scriptableObject)
                        {
                            myComponent.Reload();
                        }
                    }
                }
            }
        }
    }
}
