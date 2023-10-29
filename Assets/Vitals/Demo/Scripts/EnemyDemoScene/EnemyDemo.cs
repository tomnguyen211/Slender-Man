using System.Collections;
using UnityEngine;

namespace Vitals
{
    [RequireComponent(typeof(Health))]
    public class EnemyDemo : MonoBehaviour
    {
        public Health Health { get; private set; }
        private MeshRenderer _meshRenderer;

        private void Awake()
        {
            Health = GetComponent<Health>();
            _meshRenderer = GetComponent<MeshRenderer>();
            _originalColor = _meshRenderer.material.color;
        }

        public void Die()
        {
            Destroy(gameObject);
        }
        
        
        public void Flash()
        {
            StartCoroutine(FlashRoutine());
        }

        #region Color Flashing

        public Color flashColor = Color.red;
        public float flashDuration = 0.2f;

        private Color _originalColor;
        private bool _isFlashing;

        private IEnumerator FlashRoutine()
        {
            if (_isFlashing)
                yield break;
            _isFlashing = true;

            // Flash the object to the flash color
            Color startColor = _meshRenderer.material.color;
            float elapsedTime = 0f;
            while (elapsedTime < flashDuration)
            {
                float t = elapsedTime / flashDuration;
                _meshRenderer.material.color = Color.Lerp(startColor, flashColor, t);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            // Return the object to its original color
            startColor = _meshRenderer.material.color;
            elapsedTime = 0f;
            while (elapsedTime < flashDuration)
            {
                float t = elapsedTime / flashDuration;
                _meshRenderer.material.color = Color.Lerp(startColor, _originalColor, t);
                elapsedTime += Time.deltaTime;
                yield return null;
            }

            _meshRenderer.material.color = _originalColor;
            _isFlashing = false;
        }

        #endregion
    }
}
