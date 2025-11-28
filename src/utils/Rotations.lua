Rotations = {
    OneButtonProtection = {
        {
            abilityName = "Attack"
        },
        {
            SmartCrusaderStrike = {
                abilityName = "Crusader Strike",
                conditions = {
                    {
                        type = "buff",
                        unit = "player",
                        abilityName = "Crusader Strike",
                        actual = "isBuffed",
                        operator = "==",
                        expected = false
                    },
                    {
                        type = "buff",
                        unit = "player",
                        abilityName = "Crusader Strike",
                        actual = "timeLeft",
                        operator = "<",
                        expected = 7
                    },
                    {
                        type = "buff",
                        unit = "player",
                        abilityName = "Crusader Strike",
                        actual = "stacks",
                        operator = "<",
                        expected = 3
                    },
                }
            },
            conditions = {
                {
                    type = "buff",
                    unit = "player",
                    abilityName = "Crusader Strike",
                    actual = "stacks",
                    operator = ">=",
                    expected = 2
                }
            }
        },
        {
            abilityName = "Holy Strike"
        }
    },
    SmartCrusaderStrike = {
        {
            abilityName = "Crusader Strike",
            conditions = {
                {
                    type = "buff",
                    unit = "player",
                    abilityName = "Crusader Strike",
                    actual = "isBuffed",
                    operator = "==",
                    expected = false
                },
                {
                    type = "buff",
                    unit = "player",
                    abilityName = "Crusader Strike",
                    actual = "timeLeft",
                    operator = "<",
                    expected = 7
                },
                {
                    type = "buff",
                    unit = "player",
                    abilityName = "Crusader Strike",
                    actual = "stacks",
                    operator = "<",
                    expected = 3
                },
            }
        }
    },
    SealOfRighteousness = {
        {
            abilityName = "Attack"
        },
        {
            rotationName = "rotationSmartCrusaderStrike",
            conditions = {

            },
            {
                abilityName = "Seal of Righteousness",
                conditions = {
                    {
                        type = "buff",
                        unit = "player",
                        abilityName = "Seal of Righteousness",
                        actual = "isBuffed",
                        operator = "==",
                        expected = false
                    },
                }
            },
        },
        {
            abilityName = "Judgement",
        }
    }
}
