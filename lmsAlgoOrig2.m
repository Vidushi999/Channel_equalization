function [filtered_signal, y,fc] = lmsAlgoSelf(input, desired, step_size,order)
filter_coeff = zeros(1, order);

for i=1:1:500
    delayed_signal=input(i:i+order-1);
    filtered_signal= sum(delayed_signal.*filter_coeff);
    td=desired(i);
    tf=filtered_signal;
    esig=td-tf;
    y(i)=esig;
    filter_coeff=filter_coeff+(step_size*esig)*delayed_signal;
end
fc = filter_coeff;
end