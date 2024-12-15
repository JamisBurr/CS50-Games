using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;
using System.Collections;

public class GameOverController : MonoBehaviour
{
    public TMP_Text finalTimeText; // Reference to the TextMeshPro text element on the Canvas

    void Start()
    {
        // Retrieve the timer value from the static class and display it with "Time: " prefix
        finalTimeText.text = "Time: " + GameOverData.TimerValue;
        StartCoroutine(ReturnToStartMenuAfterDelay());
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            QuitGame();
        }
    }

    IEnumerator ReturnToStartMenuAfterDelay()
    {
        yield return new WaitForSeconds(10f); // Wait for 10 seconds
        SceneManager.LoadScene("StartMenu"); // Load the StartMenu scene
    }

    void QuitGame()
    {
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false; // Stop play mode in the editor
        #else
            Application.Quit(); // Quit the application in a build
        #endif
    }
}
