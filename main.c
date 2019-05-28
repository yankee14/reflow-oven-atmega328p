#include <inttypes.h>
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

int main(void)
{
    DDRB |= (1 << PB5);

    for(;;) {
        _delay_ms(1000);
        PORTB ^= _BV(PB5);
    }

    return 0;
}
