using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

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

    private void Awake()
    {
        for (int i = 0; i < SelectionOptions.Count; i++)
        {
            SelectionOptions[i].ItemAsset = Instantiate(SelectionOptions[i].ItemAsset);
        }
    }

    private void Start()
    {

       if (SelectionOptions.Count > 0)
        {
            //var defaultOption = SelectionOptions[0];

            var defaultOption = SelectionOptions[5];

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

            if (Input.GetKeyDown(option.InputKey) && option.hasUnlock)
            {
                if (handsController != null)
                    handsController.SetHeldItem(option.ItemAsset);

                OnItemSelected?.Invoke(option);
            }
        }
    }

    public int GetBullet(string item)
    {
        for (int i = 0; i < SelectionOptions.Count; i++)
        {
            if(SelectionOptions[i].ItemAsset.HandsPivotBoneTransformName == item)
            {
                if (SelectionOptions[i].hasUnlock)
                {
                    return SelectionOptions[i].ItemAsset.Stats.currentBullet + SelectionOptions[i].ItemAsset.Stats.totalBullet;
                }
                else
                    return 0;
            }
        }
        return 0;
    }

    public int GetIndex(string item)
    {
        for (int i = 0; i < SelectionOptions.Count; i++)
        {
            if (SelectionOptions[i].ItemAsset.HandsPivotBoneTransformName == item)
            {
                return i;
            }
        }
        return -1;
    }

    [System.Serializable]
    public class InputItemOption
    {
        public bool hasUnlock = false;
        public KeyCode InputKey;
        public FPSItem ItemAsset;

    }
}
