function [defocus_confi_n,corresp_confi_n] = NORMALIZE_CONFIDENCE(defocus_confi,corresp_confi)
%NORMALIZE_CONFIDENCE 
%           Takes both confidences, finds the maximum of both, and 
%           normalizes to 0 to 1
%           Input : defocus_confi,corresp_confi
%           Output: defocus_confi,corresp_confi

combined        = [defocus_confi corresp_confi]                           ;
combined        = combined(isfinite(combined))                            ;
defocus_confi_n = defocus_confi/max(max(combined))                        ;
corresp_confi_n = corresp_confi/max(max(combined))                        ;

end

