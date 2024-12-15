using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    public int coinTotal = 0;
    public AudioClip coinSound; // Reference to the coin sound clip
    public VictoryText victoryText; // Reference to the VictoryText script

    private bool isVictory = false;
    private float startTime; // To track the start time of the victory pause

    public void PickupCoin()
    {
        coinTotal += 1;

        AudioSource audioSource = GetComponent<AudioSource>();
        if (audioSource != null && coinSound != null)
        {
            audioSource.PlayOneShot(coinSound);
        }
        else
        {
            Debug.LogWarning("AudioSource component or coin sound clip is missing.");
        }

        Debug.Log("Coin collected! Total coins: " + coinTotal);

        if (coinTotal >= 12 && !isVictory)
        {
            StartVictoryPause();
        }
    }

    private void StartVictoryPause()
    {
        isVictory = true;

        // Pause gameplay
        Time.timeScale = 0f;

        // Display "Victory!" message
        Debug.Log("Victory!");

        // Show victory text
        victoryText.ShowVictoryText();

        // Record the start time of the victory pause
        startTime = Time.realtimeSinceStartup;
    }

    private void Update()
    {
        // Check if the victory pause duration has exceeded 10 seconds
        if (isVictory && Time.realtimeSinceStartup - startTime >= 10f)
        {
            EndVictoryPause();
        }
    }

    private void EndVictoryPause()
    {
        // Reset time scale
        Time.timeScale = 1f;

        // Reset victory state
        isVictory = false;

        // Restart the current scene
        Application.LoadLevel(Application.loadedLevel);
    }
}
