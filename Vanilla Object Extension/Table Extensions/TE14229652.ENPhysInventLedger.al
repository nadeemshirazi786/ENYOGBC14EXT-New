tableextension 14229652 "Phys. Invt. Ledger ELA" extends "Phys. Inventory Ledger Entry"
{
    fields
    {
        field(14229652; "Qty. (Phys. Count Detail)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Phys. Inv. Ledger Detail ELA"."Quantity (Count)" WHERE("Phys. Inv. Ledger Entry No." = FIELD("Entry No.")));
        }
        field(14228853; "Phys. Count Details Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Phys. Inv. Ledger Detail ELA" WHERE("Phys. Inv. Ledger Entry No." = FIELD("Entry No.")));
        }
    }

}