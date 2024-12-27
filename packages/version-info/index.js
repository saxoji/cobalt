import { existsSync } from 'node:fs';
import { join, parse } from 'node:path';
import { cwd } from 'node:process';
import { readFile } from 'node:fs/promises';

export const getVersion = async () => {
    // 환경 변수에서 버전 확인
    if (process.env.VERSION) {
        return process.env.VERSION;
    }

    try {
        // 환경 변수가 없을 경우 package.json에서 읽기 시도
        const packagePath = join(cwd(), 'package.json');
        if (existsSync(packagePath)) {
            const { version } = JSON.parse(await readFile(packagePath, 'utf8'));
            return version;
        }
    } catch (error) {
        console.warn('Warning: Could not read package.json:', error.message);
    }
    
    return 'unknown';
}

export const getBranch = async () => {
    // 환경 변수에서 브랜치 확인
    return process.env.BRANCH_NAME || 'unknown';
}

export const getRemote = async () => {
    try {
        // REPO_URL에서 저장소 정보 추출
        const repoUrl = process.env.REPO_URL;
        if (!repoUrl) return 'unknown';

        // GitHub URL에서 사용자/저장소 부분만 추출
        const match = repoUrl.match(/github\.com\/(.+?)(?:\.git)?$/);
        return match ? match[1] : 'unknown';
    } catch (error) {
        console.warn('Warning: Could not parse REPO_URL:', error.message);
        return 'unknown';
    }
}

export const getCommit = async () => {
    // 커밋 정보는 환경 변수에 없으므로 'unknown' 반환
    return 'unknown';
}
