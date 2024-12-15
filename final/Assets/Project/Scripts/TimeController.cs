using UnityEngine;
using TMPro;

public class TimerController : MonoBehaviour
{
    private float elapsedTime = 0f;
    private bool isRunning = true;
    public TMP_Text timerText;

    void Update()
    {
        if (isRunning)
        {
            elapsedTime += Time.deltaTime;
            timerText.text = "Time: " + GetFormattedTime();
        }
    }

    public void StopTimer()
    {
        isRunning = false;
    }

    public string GetFormattedTime()
    {
        int minutes = Mathf.FloorToInt(elapsedTime / 60f);
        int seconds = Mathf.FloorToInt(elapsedTime % 60f);
        int milliseconds = Mathf.FloorToInt((elapsedTime * 1000f) % 1000f);

        if (minutes > 0)
        {
            return string.Format("{0}m {1:00}s {2:000}ms", minutes, seconds, milliseconds);
        }
        else
        {
            return string.Format("{0}s {1:000}ms", seconds, milliseconds);
        }
    }
}
