using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEditor.PackageManager.Requests;
using UnityEngine;
using UnityEngine.Rendering;

// Copyright Tensori Ltd
public class AutoImport : MonoBehaviour {
    private const string PackageName = "FPS Hands Horror Pack";

    [MenuItem("FPS Hands Horror Pack/Auto import")]
    static void Handle()
    {
        if (GraphicsSettings.defaultRenderPipeline == null)
        {
            Debug.Log("Tensori auto import | Built-in render pipeline detected.");

            var importer = new Importer("com.unity.shadergraph", "com.unity.postprocessing");
            importer.Callback = PreInstallBRP;
            ImportRenderPipelinePackage("BRP");
        }
        else
        {
            if (GraphicsSettings.defaultRenderPipeline.name == "URP-HighFidelity")
            {
                Debug.Log("Tensori auto import | Universal render pipeline detected.");

                AssetDatabase.importPackageCompleted += InstallURP;
                ImportRenderPipelinePackage("URP");
            }
        }
    }

    // This is to wait until packages have installed.
    static void PreInstallBRP() {
        EditorApplication.update += InstallBRP;
    }
    
    static void InstallBRP() {
        EditorApplication.update -= InstallBRP;

        FixMaterials("BuiltInLitStandard");

        Debug.Log("Tensori auto import | Done.");
    }

    static void InstallURP(string package) {
        FixMaterials("URPLitStandard");

        Debug.Log("Tensori auto import | Done.");
    }
    
    
    static void FixMaterials(string shaderName) {
        var materials = new List<Material>();
        foreach (var asset in AssetDatabase.FindAssets("t:Material", new[] {Path.Combine("Assets", "Tensori", PackageName)}))
        {
            var path = AssetDatabase.GUIDToAssetPath(asset);
            var material = AssetDatabase.LoadMainAssetAtPath(path) as Material;
            if (material != null) {
                materials.Add(material);
                material.SetFloat("_Smoothness", 1f);
                material.SetFloat("_AO", 1f);
                material.SetFloat("_Metallic", 1f);
            }
        }
            
        var shader = FindShader(shaderName);
        foreach (var material in materials) {
            Debug.Log("Tensori auto import | Setting shader for " + material.name);
            material.shader = shader;
        }
    }
    
    static Shader FindShader(string name) {
        var shaderAssets = AssetDatabase.FindAssets("t:Shader " + name, new[] { Path.Combine("Assets", "Tensori", PackageName) });
        foreach (var shaderAsset in shaderAssets) {
            var path = AssetDatabase.GUIDToAssetPath(shaderAsset);
            var shader = AssetDatabase.LoadMainAssetAtPath(path) as Shader;
            if (shader == null) continue;
            return shader;
        }

        return null;
    }

    static void ImportRenderPipelinePackage(string pipeline) {
        var path = Path.Combine(Application.dataPath, "Tensori", PackageName, pipeline+".unitypackage");
        Debug.Log("Tensori auto import | Importing " + path);
        AssetDatabase.ImportPackage(path, false);
    }
}

// Copyright Tensori Ltd
public class Importer {
    
    public EditorApplication.CallbackFunction Callback;
    private readonly Stack<string> packages = new ();
    private AddRequest request;
    private TaskCompletionSource<bool> promise;

    public Importer(params string[] packages) {
        foreach (var package in packages) {
            this.packages.Push(package);
        }
        
        ImportNext();
    }

    private void ImportNext() {
        if (packages.Count == 0) {
            if (Callback != null) {
                Thread.Sleep(500);
                Callback.Invoke();
            }
            return;
        }
        var package = packages.Pop(); 
        Debug.Log($"Tensori auto import | Importing {package}...");
        request = Client.Add(package);
        EditorApplication.update += Progress;
    }
    
    private void Progress() {
        if (request != null && !request.IsCompleted) return;
        
        EditorApplication.update -= Progress;

        if (request.Status == StatusCode.Success) {
            Debug.Log("Tensori auto import | Installed: " + request.Result.packageId);
        } else if (request.Status >= StatusCode.Failure) {
            Debug.LogWarning("Tensori auto import | " + request.Error.message);
        }
        
        Thread.Sleep(500);
        ImportNext();
    }
} 
