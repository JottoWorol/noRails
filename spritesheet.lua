-------Spritesheet

sheetOptions =
{
    frames =
    {
        { ---1) Tree
            x = 0,
            y = 0,
            --width = 335,
            width = 375,  --задевает корову, поэтому сделал ближе к квадрату
            height = 403
        },
        { ---2) Cow
            x = 335,
            y = 0,
            --width = 301,
            --height = 403
            width = 403,
            height = 403
        },
        { ---3) train-1
            x = 335+301,
            y = 0,
            width = 256,
            height = 356
        },
        { ---4) train-2
            x = 335+301,
            y = 356,
            width = 256,
            height = 320
        },
        { ---5) Lake
            x = 0,
            y = 403,
            width = 427,
            height = 621
        },
        { ---6) rails
            x = 904 - 222,
            y = 1055 - 340,
            width = 222,
            height = 340
        }
    },
}
