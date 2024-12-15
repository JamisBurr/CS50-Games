using UnityEngine;

public class PlayerRespawn : MonoBehaviour
{
    private Vector3 startingPosition;

    void Start()
    {
        // Store the starting position when the game starts
        startingPosition = transform.position;
    }

    void Update()
    {
        // Check if the player's Y-axis position is below -20
        if (transform.position.y < -100)
        {
            // Respawn the player at the starting position
            RespawnPlayer();
        }
    }

    private void RespawnPlayer()
    {
        // Reset the player's position to the starting position
        transform.position = startingPosition;
        
        // Optionally, reset other aspects of the player's state (e.g., health, velocity)
    }
}
