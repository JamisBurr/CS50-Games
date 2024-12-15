using UnityEngine;

[CreateAssetMenu(fileName = "TileConfiguration", menuName = "Explosion Configurations/Tile Configuration")]
public class TileConfiguration : ScriptableObject
{
    public GameObject[] tiles; // Array to hold the tile references
    public GameObject explosionVFXPrefab; // Explosion VFX prefab
    public float delayBetweenRows = 1f; // Delay between each row's explosion
}
