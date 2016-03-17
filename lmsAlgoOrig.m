function [filtered_signal, y,fc] = lmsAlgoSelf(input, desired, step_size,order)

filter_coeff = zeros(1, order);
for i=1:1:500-order+1
    delayed_signal=input(i:i+order-1);
    filtered_signal(i:i+order-1)=delayed_signal.*filter_coeff;
    td=desired(i:i+order-1);
    tf=filtered_signal(i:i+order-1);
    esig=td-tf;
    y(i:i+order-1)=esig;
    filter_coeff=filter_coeff+(delayed_signal.*(step_size .*esig));
end
fc = filter_coeff;