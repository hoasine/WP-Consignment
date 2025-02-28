pageextension 58055 "User Setup Extension" extends "User Setup"
{
    layout
    {
        addafter("Allow Posting To")
        {
            field("Allow Terminate Tenant"; Rec."Allow Terminate Tenant") { }
            field("Allow Re-active Tenant"; Rec."Allow Re-active Tenant") { }
        }
    }
}