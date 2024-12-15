using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Collections;

public class StartMenuController : MonoBehaviour
{
    public GameObject titleScreenCanvas; // Reference to the title screen canvas GameObject
    public GameObject loadingScreenCanvas; // Reference to the loading screen canvas GameObject

    void Start()
    {
        titleScreenCanvas.SetActive(true); // Ensure title screen is active
        loadingScreenCanvas.SetActive(false); // Ensure loading screen is inactive
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Return))
        {
            StartCoroutine(LoadGameScene());
        }
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            QuitGame();
        }
    }

    IEnumerator LoadGameScene()
    {
        titleScreenCanvas.SetActive(false); // Deactivate the title screen
        loadingScreenCanvas.SetActive(true); // Activate the loading screen

        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync("Game");

        while (!asyncLoad.isDone)
        {
            // Optionally, display loading text or perform other actions
            yield return null;
        }
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
