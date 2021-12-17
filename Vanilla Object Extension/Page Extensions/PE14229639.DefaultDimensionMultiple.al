pageextension 14229639 "Default Dimension Multi. ELA" extends "Default Dimensions-Multiple"
{
    procedure SetMultiItem(VAR Item: Record Item)
    var
    begin
        TempDefaultDim2.DELETEALL;
        WITH Item DO
            IF FIND('-') THEN
                REPEAT
                    CopyDefaultDimToDefaultDim(DATABASE::Item, "No.");
                UNTIL NEXT = 0;
    end;

    var
        TempDefaultDim2: Record "Default Dimension";
}