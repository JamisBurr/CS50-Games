using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
public class TimeText : MonoBehaviour
{
    public GameObject player; // Reference to the player GameObject
    private Text text; // Reference to the Text component
    private float startTime; // Start time for the timer

    // Start is called before the first frame update
    void Start()
    {
        // Get the Text component attached to this GameObject
        text = GetComponent<Text>();

        // Reset the start time when the scene starts
        startTime = Time.time;
    }

    // Update is called once per frame
    void Update()
    {
        // Ensure the player reference is not null
        if (player != null)
        {
            // Calculate the current time
            float currentTime = Time.time - startTime;

            // Convert the time to minutes, seconds, and milliseconds
            int minutes = (int)(currentTime / 60);
            int seconds = (int)(currentTime % 60);
            int milliseconds = (int)((currentTime - (int)currentTime) * 100); // Extract milliseconds from fractional part

            // Update the text to display the current time
            string timeText = string.Format("Time: {0:00}:{1:00}:{2:00}", minutes, seconds, milliseconds);           
            text.text = timeText;
        }      
    }

    // Called when a new level is loaded
    void OnLevelWasLoaded(int level)
    {
        // Reset the start time when a new level is loaded
        startTime = Time.time;
    }
}
