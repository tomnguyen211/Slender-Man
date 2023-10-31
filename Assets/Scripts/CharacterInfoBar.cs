using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;

public class CharacterInfoBar : MonoBehaviour
{
    public Image healthBar;
    [SerializeField, ReadOnly]
    private float maxHealth;
    [SerializeField, ReadOnly]
    private float currentHealth;

    public Image manaBar_1;
    [SerializeField, ReadOnly]
    private float maxMana_1;
    [SerializeField, ReadOnly]
    private float currentMana_1;

    public Image manaBar_2;
    [SerializeField, ReadOnly]
    private float maxMana_2;
    [SerializeField, ReadOnly]
    private float currentMana_2;

    /*private void Start()
    {
        Init();
    }

    public void Init()
    {
        GameObject[] _player = GameObject.FindGameObjectsWithTag("Player");
        foreach (GameObject obj in _player)
        {
            if (obj.TryGetComponent<IDamage>(out IDamage healths))
            {
                currentHealth = maxHealth = healths.GetMaxHealth;
                currentMana_1 = maxMana_1 = healths.GetFirstAbilityBarMax;
                //currentMana_2 = maxMana_2 = healths.GetSeocondManaAbilityMax;
                UpdateHealthBar();
                UpdateManaBar();
                return;
            }
        }
    }*/

    public void Init(float maxH, float maxM)
    {
        currentHealth = maxHealth = maxH;
        currentMana_1 = maxMana_1 = maxM;
        UpdateHealthBar();
        UpdateManaBar();
    }


    public void SetMaxHealth(float health)
    {
        maxHealth = health;
        UpdateHealthBar();
    }

    public void SetMaxMana(float mana)
    {
        maxMana_1 = mana;
        UpdateManaBar();
    }


    void UpdateHealthBar()
    {
        float fillAmount = currentHealth / maxHealth;
        healthBar.fillAmount = fillAmount;

        if (healthBar.fillAmount <= 0f)
        {
            healthBar.fillAmount = 0f;
        }
    }

    void UpdateManaBar()
    {
        float fillAmount_1 = currentMana_1 / maxMana_1;
        manaBar_1.fillAmount = fillAmount_1;

        if (manaBar_1.fillAmount <= 0f)
        {
            manaBar_1.fillAmount = 0f;
        }

        /*float fillAmount_2 = currentMana_2 / maxMana_2;
        manaBar_2.fillAmount = fillAmount_2;

        if (manaBar_2.fillAmount <= 0f)
        {
            manaBar_2.fillAmount = 0f;
        }*/
    }

    public void TakeDamage(float damage)
    {
        currentHealth -= damage;
        currentHealth = Mathf.Clamp(currentHealth, 0f, maxHealth);
        UpdateHealthBar();
    }

    public void Heal(float amount)
    {
        currentHealth += amount;
        currentHealth = Mathf.Clamp(currentHealth, 0f, maxHealth);
        UpdateHealthBar();
    }

    public void UseMana(float amount, int type)
    {
        switch (type)
        {
            case 1:
                currentMana_1 -= amount;
                currentMana_1 = Mathf.Clamp(currentMana_1, 0f, maxMana_1);
                break;
            case 2:
                currentMana_2 -= amount;
                currentMana_2 = Mathf.Clamp(currentMana_2, 0f, maxMana_2);
                break;
        }
        UpdateManaBar();
    }

    public void RefreshMana(float amount, int type)
    {
        switch (type)
        {
            case 1:
                currentMana_1 += amount;
                currentMana_1 = Mathf.Clamp(currentMana_1, 0f, maxMana_1);
                break;
            case 2:
                currentMana_2 += amount;
                currentMana_2 = Mathf.Clamp(currentMana_2, 0f, maxMana_2);
                break;
        }
        UpdateManaBar();
    }
}
