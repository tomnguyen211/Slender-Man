using System.Collections;
using UnityEngine;

public enum CrossHairScale
{
    Default,
    Walk,
    Run,
    Shoot
}

public class CrosshairController : MonoBehaviour
{
    [SerializeField]
    private Vector3 _crosshairScale = new Vector3(0.01f, 0.01f, 0.01f);
    [SerializeField]
    private Vector3 _crossWalkScale = new Vector3(0.02f, 0.02f, 0.02f);
    [SerializeField]
    private Vector3 _crossShootScale = new Vector3(0.02f, 0.02f, 0.02f);
    [SerializeField]
    private Vector3 _crossRunScale = new Vector3(0.03f, 0.03f, 0.03f);
    [SerializeField]
    private float _scaleSpeed = 2f;

    private CrossHairScale _currentScale = default;
    private void Start()
    {
        transform.localScale = _crosshairScale;
        _currentScale = CrossHairScale.Default;
    }

    private void Update()
    {
        CrossHairController();
    }

    #region Crosshair Controller

    private void CrossHairController()
    {
        Vector3 newScale = Vector3.zero;

        switch (_currentScale)
        {
            case CrossHairScale.Default:
                newScale = _crosshairScale; break;
            case CrossHairScale.Walk:
                newScale = _crossWalkScale; break;
            case CrossHairScale.Run:
                newScale = _crossRunScale; break;
            case CrossHairScale.Shoot:
                newScale = _crossShootScale; break;
        }

        transform.localScale = Vector3.Lerp(transform.localScale, newScale, _scaleSpeed * Time.deltaTime);
    }
    public void SetScale(CrossHairScale scale)
    { _currentScale = scale; }

    public CrossHairScale GetState => _currentScale;

    public void SetScale(CrossHairScale scale, float resetTime)
    {
        if (isActiveAndEnabled)
        {
            _currentScale = scale;
            StartCoroutine(ResetCrosshair(resetTime));
        }
    }
    private IEnumerator ResetCrosshair(float resetTime)
    {
        yield return new WaitForSeconds(resetTime);
        _currentScale = CrossHairScale.Default;
    }
    #endregion
}



