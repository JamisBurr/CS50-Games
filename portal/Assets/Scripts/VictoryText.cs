using UnityEngine;
using UnityEngine.UI;

public class VictoryText : MonoBehaviour
{
    private Text textComponent;

    private void Start()
    {
        // Get the Text component
        textComponent = GetComponent<Text>();

        // Hide the text initially
        textComponent.enabled = false;
    }

    // Show the victory text
    public void ShowVictoryText()
    {
        textComponent.enabled = true;
        textComponent.text = "You Won!";
    }

    // Hide the victory text
    public void HideVictoryText()
    {
        textComponent.enabled = false;
    }
}