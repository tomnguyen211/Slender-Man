using System.Collections.Generic;
using UnityEngine;
public class TreeGenerator : MonoBehaviour
{
    [SerializeField] private bool createOnStart;
    [SerializeField] private List<GameObject> trees;
    [SerializeField] private float minSize, maxSize;
    private void Start()
    {
        if (!createOnStart) return;
        var terrain = GetComponent<Terrain>();
        var terrainData = terrain.terrainData;
        foreach (var terrainTree in terrainData.treeInstances)
        {
            var worldTreePos = Vector3.Scale(terrainTree.position, terrainData.size) + Terrain.activeTerrain.transform.position;
            var tree = Instantiate(trees[Random.Range(0, trees.Count)], worldTreePos, Quaternion.identity, transform);
            tree.transform.localScale = Vector3.one * Random.Range(minSize, maxSize);
            tree.transform.rotation = Quaternion.AngleAxis(Random.Range(-360f, 360f), Vector3.up);
        }
        terrain.treeDistance = 0;

        AstarPath.active.Scan();
    }
}
