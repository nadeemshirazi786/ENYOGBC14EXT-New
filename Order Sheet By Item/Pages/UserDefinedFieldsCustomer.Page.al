page 14228818 "User-Defined Fields - Customer"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    PageType = Card;
    SourceTable = "User-Defined Fields - Customer";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Customer No."; "Customer No.")
                {
                    ShowCaption = false;
                }
                field("Prices on Invoice"; "Prices on Invoice")
                {
                    ShowCaption = false;
                }
                field("Print Receivables"; "Print Receivables")
                {
                    ShowCaption = false;
                }
                field(Notes; Notes)
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }
}

