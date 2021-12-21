page 14228839 "Phys. Inv. Ledger Details ELA"
{

    PageType = List;
    SourceTable = "Phys. Inv. Ledger Detail ELA";
    Caption = 'Phys. Inv. Ledger Details';

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                Editable = false;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = false;
                }
                field("Quantity (Count)"; "Quantity (Count)")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Quantity (Base) (Count)"; "Quantity (Base) (Count)")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Created By"; "Created By")
                {
                    Visible = false;
                }
                field("Date Created"; "Date Created")
                {
                    Visible = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    Visible = false;
                }
                field("Modified By"; "Modified By")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

