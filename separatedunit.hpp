//////////////////////////////////////////////////////////////////////////////////////
//
// (C) Daniel Strano 2018. All rights reserved.
//
// This is an abstraction on "CoherentUnit" per https://arxiv.org/abs/1710.05867
//
// "SeparatedUnit" keeps representation of qubit states separated until explicitly
// entangled. This makes for large gains in memory and speed optimization in the
// best case scenario. "CoherentUnit" has been optimized for the worst case scenario.
//
// Licensed under the GNU General Public License V3.
// See LICENSE.md in the project root or https://www.gnu.org/licenses/gpl-3.0.en.html
// for details.

#pragma once

#include "qregister.hpp"
#include <memory>
#include <vector>

#define bitLenInt uint8_t
#define bitCapInt uint64_t
#define bitsInByte 8

namespace Qrack {

struct QbLookup {
    bitLenInt cu;
    bitLenInt qb;
};

struct QbListEntry {
    bitLenInt cu;
    bitLenInt start;
    bitLenInt length;
};

class SeparatedUnit;

class SeparatedUnit {
public:
    /// Initialize a coherent unit with qBitCount number of bits, all to |0> state.
    SeparatedUnit(bitLenInt qBitCount);

    /// Initialize a coherent unit with qBitCount number of bits, to initState unsigned integer permutation state
    SeparatedUnit(bitLenInt qBitCount, bitCapInt initState);

    /// Get a count of qubits in the SeparatedUnit
    bitLenInt GetQubitCount();

    /// Measure a bit
    bool M(bitLenInt qubitIndex);

    /// Measure permutation state of a register
    bitCapInt MReg(bitLenInt start, bitLenInt length);

protected:
    bitLenInt qubitCount;
    std::unique_ptr<QbLookup[]> qubitLookup;
    std::vector<CoherentUnit> coherentUnits;

    void GetOrderedBitList(bitLenInt start, bitLenInt length, std::vector<QbListEntry> qbList);
    void GetParallelBitList(bitLenInt start, bitLenInt length, std::vector<QbListEntry> qbList);
};
} // namespace Qrack
