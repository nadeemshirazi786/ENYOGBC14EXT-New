tableextension 51015 ItemChargeExt extends "Item Charge"
{
    fields
    {
        // field(51000; "Inherit Dimensions From Assgnt"; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(14228800; "Inherit Dim. From Assgnt ELA"; Boolean)
        // {
        //     Caption = 'Inherit Dimensions From Assgnt';
        //     DataClassification = ToBeClassified;
        //     Description = 'ENRE1.00';

        //     trigger OnValidate()
        //     begin

        //         if "Inherit Dim. From Assgnt ELA" then
        //             if Confirm(gcon000, false) then
        //                 DimMgt.DeleteDefaultDim(DATABASE::"Item Charge", "No.")
        //             else
        //                 Error(gcon001);

        //     end;
        // }
        field(14228850; "Inherit Dim From Assgnt ELA"; Boolean)
        {
            Caption = 'Inherit Dimensions From Assgnt';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF "Inherit Dim From Assgnt ELA" THEN
                    IF CONFIRM(gcon000, FALSE) THEN
                        DimMgt.DeleteDefaultDim(DATABASE::"Item Charge", "No.")
                    ELSE
                        ERROR(gcon001);
            end;
        }
    }
    var
        DimMgt: Codeunit DimensionManagement;
        gcon000: Label 'This will remove all default dimensions from the item charge. Continue?';

        gcon001: Label 'Cancelled by User.';
}