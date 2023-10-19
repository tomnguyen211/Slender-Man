using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Tensori.FPSHandsHorrorPack
{
    public class FPSItemSelector : MonoBehaviour
    {
        public List<InputItemOption> SelectionOptions = new List<InputItemOption>
        {
            new InputItemOption { InputKey = KeyCode.Alpha1, },
            new InputItemOption { InputKey = KeyCode.Alpha2, },
            new InputItemOption { InputKey = KeyCode.Alpha3, },
            new InputItemOption { InputKey = KeyCode.Alpha4, },
            new InputItemOption { InputKey = KeyCode.Alpha5, },
            new InputItemOption { InputKey = KeyCode.Alpha6, },
            new InputItemOption { InputKey = KeyCode.Alpha7, },
            new InputItemOption { InputKey = KeyCode.Alpha8, },
            new InputItemOption { InputKey = KeyCode.Alpha9, },
        };

        [Header("Object References")]
        [SerializeField] private FPSHandsController handsController = null;

        public event Action<InputItemOption> OnItemSelected = null;

        private void Start()
        {
            if (SelectionOptions.Count > 0)
            {
                var defaultOption = SelectionOptions[0];

                if (handsController != null)
                    handsController.SetHeldItem(defaultOption.ItemAsset);

                OnItemSelected?.Invoke(defaultOption);
            }
        }

        private void Update()
        {
            for (int i = 0; i < SelectionOptions.Count; i++)
            {
                var option = SelectionOptions[i];

                if (Input.GetKeyDown(option.InputKey))
                {
                    if (handsController != null)
                        handsController.SetHeldItem(option.ItemAsset);

                    OnItemSelected?.Invoke(option);
                }
            }
        }

        [System.Serializable]
        public class InputItemOption
        {
            public KeyCode InputKey;
            public FPSItem ItemAsset;
        }
    }
}