/**********************************************************************
 * TIMESTACK
 */

namespace drewfish {

    template <size_t S>
    class Timestack {
        public:
            static const size_t SIZE = S;
            uint32_t    stack[SIZE];
            size_t      next_mark;
            size_t      rollover;

            Timestack() {
                clear();
            }

            void clear() {
                for (size_t i = 0; i < SIZE; ++i) {
                    stack[i] = 0;
                }
                next_mark = 0;
                rollover = 0;
            }

            void mark() {
                stack[next_mark] = micros();
                ++next_mark;
                if (next_mark == SIZE) {
                    ++rollover;
                    next_mark = 0;
                }
            }

            void print(bool full=false) {
                size_t end = full ? SIZE : next_mark;
                Serial.println("-------------------------------------- TIMESTACK");
                for (size_t i = 0; i < end; ++i) {
                    Serial.print("-- ");
                    Serial.print(i);
                    Serial.print(" -- ");
                    Serial.print(stack[i]);
                    Serial.println("");
                }
            }
    };

};

